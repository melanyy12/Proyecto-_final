defmodule Hackathon.Distribucion.Dashboard do
  @moduledoc """
  Dashboard en tiempo real del cluster distribuido
  Muestra estado de todos los nodos, datos y tráfico
  """
  use GenServer
  require Logger

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Muestra el dashboard en la terminal
  """
  def mostrar do
    GenServer.call(__MODULE__, :mostrar_dashboard)
  end

  @doc """
  Inicia monitoreo continuo (actualiza cada N segundos)
  """
  def iniciar_monitoreo(intervalo_segundos \\ 5) do
    GenServer.cast(__MODULE__, {:iniciar_monitoreo, intervalo_segundos})
  end

  @doc """
  Detiene el monitoreo continuo
  """
  def detener_monitoreo do
    GenServer.cast(__MODULE__, :detener_monitoreo)
  end

  @doc """
  Obtiene estadísticas del cluster
  """
  def obtener_estadisticas do
    GenServer.call(__MODULE__, :estadisticas)
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    estado = %{
      monitoreo_activo: false,
      intervalo: 5,
      timer_ref: nil,
      estadisticas: inicializar_estadisticas()
    }
    {:ok, estado}
  end

  @impl true
  def handle_call(:mostrar_dashboard, _from, estado) do
    stats = recopilar_estadisticas()
    mostrar_dashboard_formateado(stats)
    {:reply, :ok, %{estado | estadisticas: stats}}
  end

  @impl true
  def handle_call(:estadisticas, _from, estado) do
    stats = recopilar_estadisticas()
    {:reply, stats, %{estado | estadisticas: stats}}
  end

  @impl true
  def handle_cast({:iniciar_monitoreo, intervalo}, estado) do
    # Cancelar timer anterior si existe
    if estado.timer_ref, do: Process.cancel_timer(estado.timer_ref)

    # Mostrar dashboard inicial
    handle_info(:actualizar_dashboard, estado)

    # Programar siguiente actualización
    timer_ref = Process.send_after(self(), :actualizar_dashboard, intervalo * 1000)

    {:noreply, %{estado | monitoreo_activo: true, intervalo: intervalo, timer_ref: timer_ref}}
  end

  @impl true
  def handle_cast(:detener_monitoreo, estado) do
    if estado.timer_ref, do: Process.cancel_timer(estado.timer_ref)
    IO.puts("\n  Monitoreo detenido\n")
    {:noreply, %{estado | monitoreo_activo: false, timer_ref: nil}}
  end

  @impl true
  def handle_info(:actualizar_dashboard, estado) do
    stats = recopilar_estadisticas()
    mostrar_dashboard_formateado(stats)

    # Programar siguiente actualización si el monitoreo está activo
    timer_ref = if estado.monitoreo_activo do
      Process.send_after(self(), :actualizar_dashboard, estado.intervalo * 1000)
    else
      nil
    end

    {:noreply, %{estado | estadisticas: stats, timer_ref: timer_ref}}
  end

  # Funciones privadas

  defp inicializar_estadisticas do
    %{
      nodos: [],
      equipos: 0,
      proyectos: 0,
      participantes: 0,
      mentores: 0,
      mensajes: 0,
      canales_activos: 0,
      memoria_total_mb: 0,
      uptime: 0
    }
  end

  defp recopilar_estadisticas do
    nodo_actual = Node.self()
    nodos_conectados = Node.list()
    todos_nodos = [nodo_actual | nodos_conectados]

    # Recopilar datos de todos los nodos
    nodos_info = Enum.map(todos_nodos, fn nodo ->
      info = if nodo == nodo_actual do
        obtener_info_local()
      else
        obtener_info_remota(nodo)
      end

      Map.put(info, :nombre, nodo)
    end)

    # Agregar estadísticas globales
    %{
      timestamp: DateTime.utc_now(),
      nodo_actual: nodo_actual,
      nodos: nodos_info,
      total_nodos: length(nodos_info),
      # Sumar datos de todos los nodos
      equipos_total: Enum.reduce(nodos_info, 0, fn n, acc -> acc + (n[:equipos] || 0) end),
      proyectos_total: Enum.reduce(nodos_info, 0, fn n, acc -> acc + (n[:proyectos] || 0) end),
      participantes_total: Enum.reduce(nodos_info, 0, fn n, acc -> acc + (n[:participantes] || 0) end),
      mentores_total: Enum.reduce(nodos_info, 0, fn n, acc -> acc + (n[:mentores] || 0) end),
      mensajes_total: Enum.reduce(nodos_info, 0, fn n, acc -> acc + (n[:mensajes] || 0) end),
      memoria_total_mb: Enum.reduce(nodos_info, 0, fn n, acc -> acc + (n[:memoria_mb] || 0) end)
    }
  end

  defp obtener_info_local do
    # Datos locales
    equipos = case Hackathon.Services.GestionEquipos.listar_equipos() do
      {:ok, e} -> length(e)
      _ -> 0
    end

    proyectos = case Hackathon.Services.GestionProyectos.listar_proyectos() do
      {:ok, p} -> length(p)
      _ -> 0
    end

    participantes = case Hackathon.Services.GestionParticipantes.listar_participantes() do
      {:ok, p} -> length(p)
      _ -> 0
    end

    mentores = case Hackathon.Services.GestionMentores.listar_mentores() do
      {:ok, m} -> length(m)
      _ -> 0
    end

    chat_stats = case Hackathon.Services.SistemaChat.obtener_estadisticas() do
      {:ok, s} -> s
      _ -> %{mensajes_enviados: 0, canales_activos: 0}
    end

    memoria = :erlang.memory()

    %{
      equipos: equipos,
      proyectos: proyectos,
      participantes: participantes,
      mentores: mentores,
      mensajes: chat_stats.mensajes_enviados,
      canales: chat_stats.canales_activos,
      memoria_mb: div(memoria[:total], 1_048_576),
      procesos: length(Process.list()),
      activo: true
    }
  end

  defp obtener_info_remota(nodo) do
    # Intentar obtener datos del nodo remoto
    timeout = 2000

    equipos = case :rpc.call(nodo, Hackathon.Services.GestionEquipos, :listar_equipos, [], timeout) do
      {:ok, e} -> length(e)
      _ -> 0
    end

    proyectos = case :rpc.call(nodo, Hackathon.Services.GestionProyectos, :listar_proyectos, [], timeout) do
      {:ok, p} -> length(p)
      _ -> 0
    end

    participantes = case :rpc.call(nodo, Hackathon.Services.GestionParticipantes, :listar_participantes, [], timeout) do
      {:ok, p} -> length(p)
      _ -> 0
    end

    mentores = case :rpc.call(nodo, Hackathon.Services.GestionMentores, :listar_mentores, [], timeout) do
      {:ok, m} -> length(m)
      _ -> 0
    end

    chat_stats = case :rpc.call(nodo, Hackathon.Services.SistemaChat, :obtener_estadisticas, [], timeout) do
      {:ok, s} -> s
      _ -> %{mensajes_enviados: 0, canales_activos: 0}
    end

    memoria = case :rpc.call(nodo, :erlang, :memory, [], timeout) do
      mem when is_list(mem) -> div(mem[:total], 1_048_576)
      _ -> 0
    end

    %{
      equipos: equipos,
      proyectos: proyectos,
      participantes: participantes,
      mentores: mentores,
      mensajes: chat_stats.mensajes_enviados,
      canales: chat_stats.canales_activos,
      memoria_mb: memoria,
      procesos: 0,
      activo: Node.ping(nodo) == :pong
    }
  end

  defp mostrar_dashboard_formateado(stats) do
    # Limpiar pantalla (comentar si no quieres que limpie)
    IO.write("\e[H\e[2J")

    IO.puts("\n")
    IO.puts("╔═══════════════════════════════════════════════════════════╗")
    IO.puts("║          CLUSTER DISTRIBUIDO - HACKATHON 2025         ║")
    IO.puts("╠═══════════════════════════════════════════════════════════╣")

    # Timestamp
    tiempo = Calendar.strftime(stats.timestamp, "%Y-%m-%d %H:%M:%S UTC")
    IO.puts("║  Última actualización: #{String.pad_trailing(tiempo, 32)} ║")
    IO.puts("╠═══════════════════════════════════════════════════════════╣")

    # Nodos
    IO.puts("║  📡 NODOS ACTIVOS (#{stats.total_nodos})                                     ║")
    Enum.each(stats.nodos, fn nodo ->
      nombre = nodo.nombre |> Atom.to_string() |> String.pad_trailing(30)
      estado = if nodo.activo, do: "✅ Activo ", else: "❌ Caído  "
      es_actual = if nodo.nombre == stats.nodo_actual, do: "★", else: " "
      IO.puts("║  #{es_actual} #{nombre} #{estado}                 ║")
    end)

    IO.puts("╠═══════════════════════════════════════════════════════════╣")

    # Datos agregados
    IO.puts("║  DATOS DEL CLUSTER                                     ║")
    IO.puts("║     Equipos:        #{String.pad_leading("#{stats.equipos_total}", 5)}                                  ║")
    IO.puts("║     Proyectos:      #{String.pad_leading("#{stats.proyectos_total}", 5)}                                  ║")
    IO.puts("║     Participantes:  #{String.pad_leading("#{stats.participantes_total}", 5)}                                  ║")
    IO.puts("║     Mentores:       #{String.pad_leading("#{stats.mentores_total}", 5)}                                  ║")
    IO.puts("║     Mensajes:       #{String.pad_leading("#{stats.mensajes_total}", 5)}                                  ║")

    IO.puts("╠═══════════════════════════════════════════════════════════╣")

    # Recursos
    IO.puts("║   RECURSOS DEL CLUSTER                                  ║")
    IO.puts("║     Memoria Total:  #{String.pad_leading("#{stats.memoria_total_mb}", 5)} MB                              ║")

    total_procesos = Enum.reduce(stats.nodos, 0, fn n, acc -> acc + (n[:procesos] || 0) end)
    IO.puts("║     Procesos:       #{String.pad_leading("#{total_procesos}", 5)}                                  ║")

    IO.puts("╠═══════════════════════════════════════════════════════════╣")

    # Detalle por nodo
    IO.puts("║    DETALLE POR NODO                                     ║")
    Enum.each(stats.nodos, fn nodo ->
      nombre_corto = nodo.nombre |> Atom.to_string() |> String.split("@") |> List.first() |> String.pad_trailing(8)
      IO.puts("║     #{nombre_corto} → E:#{String.pad_leading("#{nodo.equipos}", 2)} P:#{String.pad_leading("#{nodo.proyectos}", 2)} M:#{String.pad_leading("#{nodo.mensajes}", 3)} #{String.pad_leading("#{nodo.memoria_mb}", 4)}MB       ║")
    end)

    IO.puts("╚═══════════════════════════════════════════════════════════╝")
    IO.puts("")
  end
end
