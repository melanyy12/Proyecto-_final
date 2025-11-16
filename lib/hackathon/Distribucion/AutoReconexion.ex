defmodule Hackathon.Distribucion.AutoReconexion do
  @moduledoc """
  Sistema de auto-reconexión para nodos distribuidos
  Intenta reconectar automáticamente cuando un nodo se desconecta
  """
  use GenServer
  require Logger

  @intervalo_reconexion 5_000  # 5 segundos
  @max_intentos 10

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Activa la auto-reconexión para un nodo específico
  """
  def activar_para(nodo) when is_atom(nodo) do
    GenServer.cast(__MODULE__, {:activar, nodo})
  end

  @doc """
  Desactiva la auto-reconexión para un nodo
  """
  def desactivar_para(nodo) when is_atom(nodo) do
    GenServer.cast(__MODULE__, {:desactivar, nodo})
  end

  @doc """
  Lista los nodos con auto-reconexión activa
  """
  def nodos_monitoreados do
    GenServer.call(__MODULE__, :listar_monitoreados)
  end

  @doc """
  Obtiene estadísticas de reconexión
  """
  def estadisticas do
    GenServer.call(__MODULE__, :estadisticas)
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    # Monitorear cambios en la red de nodos
    :net_kernel.monitor_nodes(true, node_type: :all)

    estado = %{
      # Map de nodo => %{intentos: N, timer: ref, activo: bool}
      nodos_monitoreados: %{},
      reconexiones_exitosas: 0,
      reconexiones_fallidas: 0,
      nodos_perdidos: []
    }

    Logger.info(" Sistema de auto-reconexión iniciado")
    {:ok, estado}
  end

  @impl true
  def handle_cast({:activar, nodo}, estado) do
    if nodo in Node.list() or nodo == Node.self() do
      Logger.info(" Auto-reconexión activada para: #{nodo}")

      nuevo_estado = put_in(
        estado,
        [:nodos_monitoreados, nodo],
        %{intentos: 0, timer: nil, activo: true, ultima_conexion: DateTime.utc_now()}
      )

      {:noreply, nuevo_estado}
    else
      Logger.warn(" No se puede activar auto-reconexión: nodo no conectado")
      {:noreply, estado}
    end
  end

  @impl true
  def handle_cast({:desactivar, nodo}, estado) do
    Logger.info(" Auto-reconexión desactivada para: #{nodo}")

    # Cancelar timer si existe
    if estado.nodos_monitoreados[nodo][:timer] do
      Process.cancel_timer(estado.nodos_monitoreados[nodo].timer)
    end

    nuevo_estado = update_in(estado, [:nodos_monitoreados], &Map.delete(&1, nodo))
    {:noreply, nuevo_estado}
  end

  @impl true
  def handle_call(:listar_monitoreados, _from, estado) do
    nodos = Map.keys(estado.nodos_monitoreados)
    {:reply, nodos, estado}
  end

  @impl true
  def handle_call(:estadisticas, _from, estado) do
    stats = %{
      nodos_monitoreados: map_size(estado.nodos_monitoreados),
      reconexiones_exitosas: estado.reconexiones_exitosas,
      reconexiones_fallidas: estado.reconexiones_fallidas,
      nodos_perdidos: estado.nodos_perdidos
    }
    {:reply, stats, estado}
  end

  @impl true
  def handle_info({:nodedown, nodo, _info}, estado) do
    # Un nodo se desconectó
    if Map.has_key?(estado.nodos_monitoreados, nodo) do
      Logger.warn(" Nodo desconectado (monitoreado): #{nodo}")
      Logger.info(" Iniciando intentos de reconexión...")

      # Programar primer intento de reconexión
      timer = Process.send_after(self(), {:intentar_reconexion, nodo}, @intervalo_reconexion)

      nuevo_estado = put_in(
        estado,
        [:nodos_monitoreados, nodo],
        %{intentos: 1, timer: timer, activo: false, desconexion: DateTime.utc_now()}
      )

      {:noreply, nuevo_estado}
    else
      {:noreply, estado}
    end
  end

  @impl true
  def handle_info({:nodeup, nodo, _info}, estado) do
    # Un nodo se reconectó (posiblemente por nosotros)
    if Map.has_key?(estado.nodos_monitoreados, nodo) do
      Logger.info(" Nodo reconectado exitosamente: #{nodo}")

      # Cancelar timer si existe
      if estado.nodos_monitoreados[nodo][:timer] do
        Process.cancel_timer(estado.nodos_monitoreados[nodo].timer)
      end

      nuevo_estado = estado
      |> put_in([:nodos_monitoreados, nodo, :activo], true)
      |> put_in([:nodos_monitoreados, nodo, :timer], nil)
      |> put_in([:nodos_monitoreados, nodo, :intentos], 0)
      |> put_in([:nodos_monitoreados, nodo, :ultima_conexion], DateTime.utc_now())
      |> update_in([:reconexiones_exitosas], &(&1 + 1))

      {:noreply, nuevo_estado}
    else
      {:noreply, estado}
    end
  end

  @impl true
  def handle_info({:intentar_reconexion, nodo}, estado) do
    info_nodo = estado.nodos_monitoreados[nodo]

    if info_nodo && info_nodo.intentos <= @max_intentos do
      Logger.info(" Intento #{info_nodo.intentos}/#{@max_intentos} de reconexión a: #{nodo}")

      case Hackathon.Distribucion.Nodo.conectar_nodo(nodo) do
        {:ok, :conectado} ->
          Logger.info(" Reconexión exitosa a: #{nodo}")

          nuevo_estado = estado
          |> put_in([:nodos_monitoreados, nodo, :activo], true)
          |> put_in([:nodos_monitoreados, nodo, :timer], nil)
          |> put_in([:nodos_monitoreados, nodo, :intentos], 0)
          |> update_in([:reconexiones_exitosas], &(&1 + 1))

          {:noreply, nuevo_estado}

        {:ok, :ya_conectado} ->
          Logger.info(" Nodo ya estaba conectado: #{nodo}")
          {:noreply, put_in(estado, [:nodos_monitoreados, nodo, :activo], true)}

        {:error, _} ->
          # Programar siguiente intento
          if info_nodo.intentos < @max_intentos do
            timer = Process.send_after(self(), {:intentar_reconexion, nodo}, @intervalo_reconexion)

            nuevo_estado = estado
            |> update_in([:nodos_monitoreados, nodo, :intentos], &(&1 + 1))
            |> put_in([:nodos_monitoreados, nodo, :timer], timer)

            {:noreply, nuevo_estado}
          else
            Logger.error(" Máximo de intentos alcanzado para: #{nodo}")
            Logger.warn(" Nodo marcado como perdido: #{nodo}")

            nuevo_estado = estado
            |> update_in([:nodos_perdidos], &[nodo | &1])
            |> update_in([:reconexiones_fallidas], &(&1 + 1))
            |> update_in([:nodos_monitoreados], &Map.delete(&1, nodo))

            {:noreply, nuevo_estado}
          end
      end
    else
      {:noreply, estado}
    end
  end

  @impl true
  def handle_info(_msg, estado) do
    {:noreply, estado}
  end
end
