defmodule Hackathon.Metricas.Monitor do
  @moduledoc """
  Sistema de monitoreo y métricas en tiempo real
  """
  use GenServer

  alias Hackathon.Services.{GestionEquipos, GestionProyectos, GestionParticipantes, GestionMentores, SistemaChat}

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @doc """
  Obtiene todas las métricas del sistema
  """
  def obtener_metricas do
    GenServer.call(__MODULE__, :obtener_metricas)
  end

  @doc """
  Obtiene métricas de rendimiento
  """
  def obtener_rendimiento do
    GenServer.call(__MODULE__, :obtener_rendimiento)
  end

  @doc """
  Obtiene estadísticas de actividad
  """
  def obtener_actividad do
    GenServer.call(__MODULE__, :obtener_actividad)
  end

  @doc """
  Reinicia el monitoreo
  """
  def reiniciar_metricas do
    GenServer.cast(__MODULE__, :reiniciar)
  end

  # Server Callbacks

  @impl true
  def init(:ok) do
    # Inicializar tabla ETS para métricas
    :ets.new(:metricas_sistema, [:set, :public, :named_table])

    estado = %{
      inicio: DateTime.utc_now(),
      ultima_actualizacion: DateTime.utc_now(),
      ciclos_actualizacion: 0
    }

    # Programar actualización periódica
    schedule_update()

    {:ok, estado}
  end

  @impl true
  def handle_call(:obtener_metricas, _from, estado) do
    metricas = calcular_metricas_completas()
    {:reply, {:ok, metricas}, estado}
  end

  @impl true
  def handle_call(:obtener_rendimiento, _from, estado) do
    rendimiento = calcular_rendimiento()
    {:reply, {:ok, rendimiento}, estado}
  end

  @impl true
  def handle_call(:obtener_actividad, _from, estado) do
    actividad = calcular_actividad()
    {:reply, {:ok, actividad}, estado}
  end

  @impl true
  def handle_cast(:reiniciar, _estado) do
    :ets.delete_all_objects(:metricas_sistema)
    nuevo_estado = %{
      inicio: DateTime.utc_now(),
      ultima_actualizacion: DateTime.utc_now(),
      ciclos_actualizacion: 0
    }
    {:noreply, nuevo_estado}
  end

  @impl true
  def handle_info(:actualizar_metricas, estado) do
    # Actualizar métricas en ETS
    actualizar_metricas_ets()

    nuevo_estado = %{
      estado |
      ultima_actualizacion: DateTime.utc_now(),
      ciclos_actualizacion: estado.ciclos_actualizacion + 1
    }

    # Programar siguiente actualización
    schedule_update()

    {:noreply, nuevo_estado}
  end

  # Funciones privadas

  defp schedule_update do
    # Actualizar cada 30 segundos
    Process.send_after(self(), :actualizar_metricas, 30_000)
  end

  defp calcular_metricas_completas do
    %{
      sistema: metricas_sistema(),
      equipos: metricas_equipos(),
      proyectos: metricas_proyectos(),
      usuarios: metricas_usuarios(),
      chat: metricas_chat(),
      rendimiento: calcular_rendimiento()
    }
  end

  defp metricas_sistema do
    memoria = :erlang.memory()

    %{
      uptime_segundos: calcular_uptime(),
      procesos_activos: length(Process.list()),
      memoria_total_mb: div(memoria[:total], 1_048_576),
      memoria_procesos_mb: div(memoria[:processes], 1_048_576),
      memoria_sistema_mb: div(memoria[:system], 1_048_576),
      schedulers: :erlang.system_info(:schedulers_online)
    }
  end

  defp metricas_equipos do
    case GestionEquipos.listar_equipos() do
      {:ok, equipos} ->
        equipos_activos = Enum.filter(equipos, & &1.activo)
        equipos_completos = Enum.filter(equipos, &Hackathon.Domain.Equipo.completo?/1)

        %{
          total: length(equipos),
          activos: length(equipos_activos),
          completos: length(equipos_completos),
          promedio_miembros: calcular_promedio_miembros(equipos),
          por_categoria: agrupar_por_categoria(equipos)
        }

      _ ->
        %{total: 0, activos: 0, completos: 0, promedio_miembros: 0, por_categoria: %{}}
    end
  end

  defp metricas_proyectos do
    case GestionProyectos.listar_proyectos() do
      {:ok, proyectos} ->
        %{
          total: length(proyectos),
          por_estado: agrupar_proyectos_por_estado(proyectos),
          por_categoria: agrupar_proyectos_por_categoria(proyectos),
          total_avances: contar_avances_totales(proyectos),
          promedio_avances: calcular_promedio_avances(proyectos),
          con_retroalimentacion: contar_con_retroalimentacion(proyectos)
        }

      _ ->
        %{total: 0, por_estado: %{}, por_categoria: %{}, total_avances: 0, promedio_avances: 0}
    end
  end

  defp metricas_usuarios do
    participantes_result = GestionParticipantes.listar_participantes()
    mentores_result = GestionMentores.listar_mentores()

    participantes = case participantes_result do
      {:ok, p} -> p
      _ -> []
    end

    mentores = case mentores_result do
      {:ok, m} -> m
      _ -> []
    end

    participantes_con_equipo = Enum.count(participantes, fn p -> p.equipo_id != nil end)
    mentores_ocupados = Enum.count(mentores, fn m -> length(m.equipos_asignados) > 0 end)

    %{
      total_participantes: length(participantes),
      participantes_con_equipo: participantes_con_equipo,
      participantes_sin_equipo: length(participantes) - participantes_con_equipo,
      total_mentores: length(mentores),
      mentores_activos: mentores_ocupados,
      mentores_disponibles: length(mentores) - mentores_ocupados
    }
  end

  defp metricas_chat do
    case SistemaChat.obtener_estadisticas() do
      {:ok, stats} ->
        stats

      _ ->
        %{mensajes_enviados: 0, canales_activos: 0, suscriptores_totales: 0}
    end
  end

  defp calcular_rendimiento do
    # Métricas de rendimiento del sistema
    {reductions, _} = :erlang.statistics(:reductions)
    {runtime, _} = :erlang.statistics(:runtime)
    {wall_clock, _} = :erlang.statistics(:wall_clock)

    gc_stats = :erlang.statistics(:garbage_collection)
    {gc_count, gc_words, _} = gc_stats

    %{
      reducciones_totales: reductions,
      tiempo_ejecucion_ms: runtime,
      tiempo_real_ms: wall_clock,
      garbage_collections: gc_count,
      memoria_gc_recuperada_mb: div(gc_words * 8, 1_048_576),
      eficiencia_cpu: if(wall_clock > 0, do: runtime / wall_clock * 100, else: 0.0)
    }
  end

  defp calcular_actividad do
    # Estadísticas de actividad reciente
    %{
      sesiones_activas: contar_sesiones_activas(),
      operaciones_recientes: obtener_operaciones_recientes()
    }
  end

  defp actualizar_metricas_ets do
    timestamp = DateTime.utc_now()

    metricas = calcular_metricas_completas()

    :ets.insert(:metricas_sistema, {:ultima_actualizacion, timestamp})
    :ets.insert(:metricas_sistema, {:metricas, metricas})
  end

  defp calcular_uptime do
    case :ets.lookup(:metricas_sistema, :inicio) do
      [{:inicio, inicio}] ->
        DateTime.diff(DateTime.utc_now(), inicio, :second)

      [] ->
        0
    end
  end

  defp calcular_promedio_miembros([]), do: 0
  defp calcular_promedio_miembros(equipos) do
    total_miembros = Enum.reduce(equipos, 0, fn equipo, acc ->
      acc + length(equipo.miembros)
    end)

    Float.round(total_miembros / length(equipos), 2)
  end

  defp agrupar_por_categoria(equipos) do
    Enum.reduce(equipos, %{}, fn equipo, acc ->
      Map.update(acc, equipo.categoria, 1, &(&1 + 1))
    end)
  end

  defp agrupar_proyectos_por_estado(proyectos) do
    Enum.reduce(proyectos, %{}, fn proyecto, acc ->
      Map.update(acc, proyecto.estado, 1, &(&1 + 1))
    end)
  end

  defp agrupar_proyectos_por_categoria(proyectos) do
    Enum.reduce(proyectos, %{}, fn proyecto, acc ->
      Map.update(acc, proyecto.categoria, 1, &(&1 + 1))
    end)
  end

  defp contar_avances_totales(proyectos) do
    Enum.reduce(proyectos, 0, fn proyecto, acc ->
      acc + length(proyecto.avances)
    end)
  end

  defp calcular_promedio_avances([]), do: 0
  defp calcular_promedio_avances(proyectos) do
    total = contar_avances_totales(proyectos)
    Float.round(total / length(proyectos), 2)
  end

  defp contar_con_retroalimentacion(proyectos) do
    Enum.count(proyectos, fn p -> length(p.retroalimentacion) > 0 end)
  end

  defp contar_sesiones_activas do
    case :ets.info(:sesiones) do
      :undefined -> 0
      info -> Keyword.get(info, :size, 0)
    end
  end

  defp obtener_operaciones_recientes do
    # Implementar según necesidad
    %{
      ultimos_5_minutos: 0,
      ultima_hora: 0
    }
  end
end
