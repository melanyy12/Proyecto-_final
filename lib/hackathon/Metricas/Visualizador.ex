defmodule Hackathon.Metricas.Visualizador do
  @moduledoc """
  Visualiza las métricas del sistema en la CLI
  """

  alias Hackathon.Metricas.Monitor

  def mostrar_dashboard do
    case Monitor.obtener_metricas() do
      {:ok, metricas} ->
        IO.puts("\n")
        IO.puts("╔══════════════════════════════════════════════════════════╗")
        IO.puts("║       DASHBOARD DE MÉTRICAS - CODE4FUTURE 2025          ║")
        IO.puts("╚══════════════════════════════════════════════════════════╝")
        IO.puts("")

        mostrar_seccion_sistema(metricas.sistema)
        mostrar_seccion_equipos(metricas.equipos)
        mostrar_seccion_proyectos(metricas.proyectos)
        mostrar_seccion_usuarios(metricas.usuarios)
        mostrar_seccion_chat(metricas.chat)
        mostrar_seccion_rendimiento(metricas.rendimiento)

        IO.puts("\n╚══════════════════════════════════════════════════════════╝\n")

      _ ->
        IO.puts("\nError al obtener métricas\n")
    end
  end

  defp mostrar_seccion_sistema(sistema) do
    IO.puts("┌─ SISTEMA")
    IO.puts("│  Uptime: #{formatear_tiempo(sistema.uptime_segundos)}")
    IO.puts("│  Procesos: #{sistema.procesos_activos}")
    IO.puts("│  Memoria Total: #{sistema.memoria_total_mb} MB")
    IO.puts("│  Memoria Procesos: #{sistema.memoria_procesos_mb} MB")
    IO.puts("│  Schedulers: #{sistema.schedulers}")
    IO.puts("│")
  end

  defp mostrar_seccion_equipos(equipos) do
    IO.puts("┌─ EQUIPOS")
    IO.puts("│  Total: #{equipos.total}")
    IO.puts("│  Activos: #{equipos.activos}")
    IO.puts("│  Completos: #{equipos.completos}")
    IO.puts("│  Promedio miembros: #{equipos.promedio_miembros}")

    if map_size(equipos.por_categoria) > 0 do
      IO.puts("│  Por categoría:")
      Enum.each(equipos.por_categoria, fn {cat, count} ->
        IO.puts("│    • #{cat}: #{count}")
      end)
    end

    IO.puts("│")
  end

  defp mostrar_seccion_proyectos(proyectos) do
    IO.puts("┌─ PROYECTOS")
    IO.puts("│  Total: #{proyectos.total}")
    IO.puts("│  Avances totales: #{proyectos.total_avances}")
    IO.puts("│  Promedio avances: #{proyectos.promedio_avances}")
    IO.puts("│  Con retroalimentación: #{proyectos.con_retroalimentacion}")

    if map_size(proyectos.por_estado) > 0 do
      IO.puts("│  Por estado:")
      Enum.each(proyectos.por_estado, fn {estado, count} ->
        IO.puts("│    • #{estado}: #{count}")
      end)
    end

    IO.puts("│")
  end

  defp mostrar_seccion_usuarios(usuarios) do
    IO.puts("┌─ USUARIOS")
    IO.puts("│  Participantes: #{usuarios.total_participantes}")
    IO.puts("│    • Con equipo: #{usuarios.participantes_con_equipo}")
    IO.puts("│    • Sin equipo: #{usuarios.participantes_sin_equipo}")
    IO.puts("│  Mentores: #{usuarios.total_mentores}")
    IO.puts("│    • Activos: #{usuarios.mentores_activos}")
    IO.puts("│    • Disponibles: #{usuarios.mentores_disponibles}")
    IO.puts("│")
  end

  defp mostrar_seccion_chat(chat) do
    IO.puts("┌─ SISTEMA DE CHAT")
    IO.puts("│  Mensajes enviados: #{chat.mensajes_enviados}")
    IO.puts("│  Canales activos: #{chat.canales_activos}")
    IO.puts("│  Suscriptores: #{chat.suscriptores_totales}")
    IO.puts("│")
  end

  defp mostrar_seccion_rendimiento(rendimiento) do
    IO.puts("┌─ RENDIMIENTO")
    IO.puts("│  Tiempo ejecución: #{rendimiento.tiempo_ejecucion_ms} ms")
    IO.puts("│  Tiempo real: #{rendimiento.tiempo_real_ms} ms")
    IO.puts("│  Eficiencia CPU: #{Float.round(rendimiento.eficiencia_cpu, 2)}%")
    IO.puts("│  Garbage Collections: #{rendimiento.garbage_collections}")
    IO.puts("│  Memoria recuperada: #{rendimiento.memoria_gc_recuperada_mb} MB")
  end

  defp formatear_tiempo(segundos) when segundos < 60 do
    "#{segundos}s"
  end

  defp formatear_tiempo(segundos) when segundos < 3600 do
    minutos = div(segundos, 60)
    segundos_rest = rem(segundos, 60)
    "#{minutos}m #{segundos_rest}s"
  end

  defp formatear_tiempo(segundos) do
    horas = div(segundos, 3600)
    minutos = div(rem(segundos, 3600), 60)
    "#{horas}h #{minutos}m"
  end
end
