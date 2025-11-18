defmodule Hackathon.Services.SistemaChat do
  @moduledoc """
  Sistema de chat distribuido con sincronización entre nodos
  """
  use GenServer

  alias Hackathon.Domain.Mensaje
  alias Hackathon.Adapters.Persistencia.RepositorioMensajes

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: {:global, __MODULE__}])
  end

  @doc """
  Envía un mensaje a un canal específico (distribuido)
  """
  def enviar_mensaje(emisor_id, contenido, canal) do
    # Usar :global para acceder al GenServer en cualquier nodo
    case :global.whereis_name(__MODULE__) do
      :undefined ->
        {:error, "Sistema de chat no disponible"}
      pid ->
        GenServer.call(pid, {:enviar_mensaje, emisor_id, contenido, canal})
    end
  end

  @doc """
  Obtiene el historial de mensajes de un canal
  """
  def obtener_historial(canal) do
    case :global.whereis_name(__MODULE__) do
      :undefined ->
        {:error, "Sistema de chat no disponible"}
      pid ->
        GenServer.call(pid, {:historial, canal})
    end
  end

  @doc """
  Suscribe un proceso para recibir notificaciones de un canal
  """
  def suscribirse_canal(canal, pid \\ self()) do
    case :global.whereis_name(__MODULE__) do
      :undefined ->
        {:error, "Sistema de chat no disponible"}
      server_pid ->
        GenServer.cast(server_pid, {:suscribir, canal, pid})
    end
  end

  @doc """
  Desuscribe un proceso de un canal
  """
  def desuscribirse_canal(canal, pid \\ self()) do
    case :global.whereis_name(__MODULE__) do
      :undefined ->
        {:error, "Sistema de chat no disponible"}
      server_pid ->
        GenServer.cast(server_pid, {:desuscribir, canal, pid})
    end
  end

  @doc """
  Obtiene estadísticas del sistema de chat
  """
  def obtener_estadisticas do
    case :global.whereis_name(__MODULE__) do
      :undefined ->
        {:error, "Sistema de chat no disponible"}
      pid ->
        GenServer.call(pid, :estadisticas)
    end
  end

  # Server Callbacks

  @impl true
  def init(:ok) do
    # Inicializar tabla ETS para suscriptores (local al nodo)
    tabla = :ets.new(:chat_suscriptores, [:bag, :public])

    estado = %{
      mensajes_enviados: 0,
      canales_activos: MapSet.new(),
      inicio: DateTime.utc_now(),
      tabla_suscriptores: tabla
    }

    {:ok, estado}
  end

  @impl true
  def handle_call({:enviar_mensaje, emisor_id, contenido, canal}, _from, estado) do
    # Crear mensaje
    mensaje = Mensaje.nuevo(generar_id(), emisor_id, contenido, canal)

    # Guardar en persistencia de forma asíncrona
    Task.start(fn ->
      RepositorioMensajes.guardar(mensaje)
    end)

    # Notificar a suscriptores LOCALES
    Task.start(fn ->
      notificar_suscriptores_locales(estado.tabla_suscriptores, canal, mensaje)
    end)

    # IMPORTANTE: Broadcast a todos los nodos conectados
    Task.start(fn ->
      broadcast_a_nodos({:nuevo_mensaje, canal, mensaje})
    end)

    # Actualizar estadísticas
    nuevo_estado = %{
      estado |
      mensajes_enviados: estado.mensajes_enviados + 1,
      canales_activos: MapSet.put(estado.canales_activos, canal)
    }

    {:reply, {:ok, mensaje}, nuevo_estado}
  end

  @impl true
  def handle_call({:historial, canal}, _from, estado) do
    # Obtener historial de forma asíncrona
    task = Task.async(fn ->
      case RepositorioMensajes.obtener_por_canal(canal) do
        {:ok, mensajes} -> mensajes
        _ -> []
      end
    end)

    mensajes = Task.await(task, 5000)
    {:reply, {:ok, mensajes}, estado}
  end

  @impl true
  def handle_call(:estadisticas, _from, estado) do
    canales_count = MapSet.size(estado.canales_activos)
    suscriptores_count = :ets.info(estado.tabla_suscriptores, :size)
    tiempo_activo = DateTime.diff(DateTime.utc_now(), estado.inicio, :second)

    stats = %{
      mensajes_enviados: estado.mensajes_enviados,
      canales_activos: canales_count,
      suscriptores_totales: suscriptores_count,
      tiempo_activo_segundos: tiempo_activo,
      inicio: estado.inicio
    }

    {:reply, {:ok, stats}, estado}
  end

  @impl true
  def handle_cast({:suscribir, canal, pid}, estado) do
    :ets.insert(estado.tabla_suscriptores, {canal, pid})
    Process.monitor(pid)
    {:noreply, estado}
  end

  @impl true
  def handle_cast({:desuscribir, canal, pid}, estado) do
    :ets.match_delete(estado.tabla_suscriptores, {canal, pid})
    {:noreply, estado}
  end

  # NUEVO: Manejar mensajes de otros nodos
  @impl true
  def handle_cast({:mensaje_remoto, canal, mensaje}, estado) do
    # Notificar solo a suscriptores locales
    Task.start(fn ->
      notificar_suscriptores_locales(estado.tabla_suscriptores, canal, mensaje)
    end)

    nuevo_estado = %{
      estado |
      mensajes_enviados: estado.mensajes_enviados + 1,
      canales_activos: MapSet.put(estado.canales_activos, canal)
    }

    {:noreply, nuevo_estado}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, estado) do
    # Limpiar suscripciones del proceso caído
    :ets.match_delete(estado.tabla_suscriptores, {:_, pid})
    {:noreply, estado}
  end

  @impl true
  def handle_info(_msg, estado) do
    {:noreply, estado}
  end

  # Funciones privadas

  defp notificar_suscriptores_locales(tabla, canal, mensaje) do
    suscriptores = :ets.lookup(tabla, canal)

    suscriptores
    |> Enum.map(fn {_canal, pid} ->
      Task.async(fn ->
        if Process.alive?(pid) do
          send(pid, {:nuevo_mensaje, mensaje})
        end
      end)
    end)
    |> Enum.each(&Task.await(&1, 1000))
  end

  defp broadcast_a_nodos({:nuevo_mensaje, canal, mensaje}) do
    # Enviar mensaje a todos los nodos conectados
    nodos = Node.list()

    Enum.each(nodos, fn nodo ->
      # Usar :global para encontrar el GenServer en el nodo remoto
      case :rpc.call(nodo, :global, :whereis_name, [__MODULE__], 2000) do
        pid when is_pid(pid) ->
          GenServer.cast(pid, {:mensaje_remoto, canal, mensaje})
        _ ->
          :ok
      end
    end)
  end

  defp generar_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  # ============================================
  # FUNCIONES PARA SALAS TEMÁTICAS (distribuidas)
  # ============================================

  @doc """
  Envía un mensaje a una sala temática (distribuido)
  """
  def enviar_mensaje_sala(emisor_id, contenido, sala_id) do
    case Hackathon.Services.GestionSalas.obtener_sala(sala_id) do
      {:ok, sala} ->
        if emisor_id in sala.miembros or emisor_id == sala.creador_id do
          canal = "sala_#{sala_id}"
          enviar_mensaje(emisor_id, contenido, canal)
        else
          {:error, "No perteneces a esta sala"}
        end

      {:error, :no_encontrado} ->
        {:error, "Sala no encontrada"}

      error ->
        error
    end
  end

  @doc """
  Obtiene el historial de mensajes de una sala
  """
  def obtener_historial_sala(sala_id, usuario_id) do
    case Hackathon.Services.GestionSalas.obtener_sala(sala_id) do
      {:ok, sala} ->
        if usuario_id in sala.miembros or usuario_id == sala.creador_id or sala.publica do
          canal = "sala_#{sala_id}"
          obtener_historial(canal)
        else
          {:error, "No tienes acceso a esta sala"}
        end

      error ->
        error
    end
  end

  @doc """
  Obtiene estadísticas de una sala específica
  """
  def obtener_estadisticas_sala(sala_id) do
    canal = "sala_#{sala_id}"

    case obtener_historial(canal) do
      {:ok, mensajes} ->
        stats = %{
          total_mensajes: length(mensajes),
          participantes_activos: mensajes
            |> Enum.map(& &1.emisor_id)
            |> Enum.uniq()
            |> length(),
          ultimo_mensaje: List.first(mensajes),
          mensajes_hoy: contar_mensajes_hoy(mensajes)
        }
        {:ok, stats}

      error ->
        error
    end
  end

  defp contar_mensajes_hoy(mensajes) do
    hoy = Date.utc_today()

    Enum.count(mensajes, fn mensaje ->
      fecha_mensaje = DateTime.to_date(mensaje.fecha)
      Date.compare(fecha_mensaje, hoy) == :eq
    end)
  end
end
