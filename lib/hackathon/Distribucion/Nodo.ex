defmodule Hackathon.Distribucion.Nodo do
  @moduledoc """
  Gestión de nodos distribuidos para la hackathon
  Permite conectar múltiples computadoras en la misma red
  """
  use GenServer
  require Logger

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Conecta este nodo a otro nodo en la red
  Ejemplo: Nodo.conectar_nodo(:"hackathon@192.168.1.20")
  """
  def conectar_nodo(nodo_remoto) when is_atom(nodo_remoto) do
    GenServer.call(__MODULE__, {:conectar, nodo_remoto})
  end

  @doc """
  Lista todos los nodos conectados
  """
  def listar_nodos_conectados do
    GenServer.call(__MODULE__, :listar_nodos)
  end

  @doc """
  Obtiene información del nodo actual
  """
  def info_nodo_actual do
    %{
      nombre: Node.self(),
      cookie: Node.get_cookie(),
      nodos_conectados: Node.list(),
      vivo?: Node.alive?()
    }
  end

  @doc """
  Sincroniza datos entre todos los nodos
  """
  def sincronizar_datos do
    GenServer.cast(__MODULE__, :sincronizar)
  end

  @doc """
  Envía un mensaje a todos los nodos conectados
  """
  def broadcast(mensaje) do
    GenServer.cast(__MODULE__, {:broadcast, mensaje})
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    # Monitorear nodos que se conectan/desconectan
    :net_kernel.monitor_nodes(true)

    estado = %{
      nodos_conocidos: MapSet.new(),
      ultima_sincronizacion: DateTime.utc_now(),
      mensajes_broadcast: []
    }

    Logger.info("Nodo distribuido iniciado: #{Node.self()}")

    {:ok, estado}
  end

  @impl true
  def handle_call({:conectar, nodo_remoto}, _from, estado) do
    Logger.info(" Intentando conectar con: #{nodo_remoto}")

    case Node.connect(nodo_remoto) do
      true ->
        nuevos_nodos = MapSet.put(estado.nodos_conocidos, nodo_remoto)
        Logger.info(" Conectado exitosamente a: #{nodo_remoto}")
        Logger.info(" Nodos activos: #{inspect(Node.list())}")

        # Sincronizar datos automáticamente
        sincronizar_con_nodo(nodo_remoto)

        {:reply, {:ok, :conectado}, %{estado | nodos_conocidos: nuevos_nodos}}

      false ->
        Logger.error(" No se pudo conectar con: #{nodo_remoto}")
        {:reply, {:error, :conexion_fallida}, estado}

      :ignored ->
        Logger.warning("  Nodo ya conectado: #{nodo_remoto}")
        {:reply, {:ok, :ya_conectado}, estado}
    end
  end

  @impl true
  def handle_call(:listar_nodos, _from, estado) do
    nodos = %{
      conectados: Node.list(),
      conocidos: MapSet.to_list(estado.nodos_conocidos),
      total: length(Node.list())
    }

    {:reply, {:ok, nodos}, estado}
  end

  @impl true
  def handle_cast(:sincronizar, estado) do
    Logger.info(" Sincronizando datos con todos los nodos...")

    Enum.each(Node.list(), fn nodo ->
      sincronizar_con_nodo(nodo)
    end)

    nuevo_estado = %{estado | ultima_sincronizacion: DateTime.utc_now()}
    {:noreply, nuevo_estado}
  end

  @impl true
  def handle_cast({:broadcast, mensaje}, estado) do
    Logger.info(" Broadcasting mensaje a #{length(Node.list())} nodos")

    Enum.each(Node.list(), fn nodo ->
      :rpc.cast(nodo, __MODULE__, :recibir_broadcast, [mensaje, Node.self()])
    end)

    {:noreply, estado}
  end

  @impl true
  def handle_info({:nodeup, nodo}, estado) do
    Logger.info(" Nodo conectado: #{nodo}")
    nuevos_nodos = MapSet.put(estado.nodos_conocidos, nodo)

    # Notificar a la aplicación (si tienes PubSub disponible)
    # Phoenix.PubSub.broadcast(
    #   Hackathon.PubSub,
    #   "nodos",
    #   {:nodo_conectado, nodo}
    # )

    {:noreply, %{estado | nodos_conocidos: nuevos_nodos}}
  end

  @impl true
  def handle_info({:nodedown, nodo}, estado) do
    Logger.warning(" Nodo desconectado: #{nodo}")

    # Notificar a la aplicación (si tienes PubSub disponible)
    # Phoenix.PubSub.broadcast(
    #   Hackathon.PubSub,
    #   "nodos",
    #   {:nodo_desconectado, nodo}
    # )

    {:noreply, estado}
  end

  # Funciones auxiliares

  defp sincronizar_con_nodo(nodo) do
    Logger.debug(" Sincronizando con #{nodo}...")

    # Sincronizar equipos
    case :rpc.call(nodo, Hackathon.Services.GestionEquipos, :listar_equipos, []) do
      {:ok, equipos_remotos} ->
        Logger.debug("  ✓ Recibidos #{length(equipos_remotos)} equipos de #{nodo}")

      {:badrpc, reason} ->
        Logger.error("  Error sincronizando equipos: #{inspect(reason)}")

      _ ->
        Logger.warning("    Respuesta inesperada de #{nodo}")
    end
  end

  @doc """
  Función pública para recibir broadcasts de otros nodos
  """
  def recibir_broadcast(mensaje, nodo_origen) do
    Logger.info(" Broadcast recibido de #{nodo_origen}: #{inspect(mensaje)}")

    # Procesar el mensaje según su tipo
    case mensaje do
      {:nuevo_equipo, equipo} ->
        IO.puts("\n Nuevo equipo creado en #{nodo_origen}: #{equipo.nombre}")

      {:nuevo_proyecto, proyecto} ->
        IO.puts("\n Nuevo proyecto en #{nodo_origen}: #{proyecto.nombre}")

      {:nuevo_mensaje, canal, _contenido} ->
        IO.puts("\n Mensaje en #{canal} desde #{nodo_origen}")

      _ ->
        Logger.debug("Mensaje broadcast desconocido: #{inspect(mensaje)}")
    end
  end
end
