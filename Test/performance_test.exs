# test/performance_test.exs
defmodule HackathonPerformanceTest do
  use ExUnit.Case

  alias Hackathon.Services.{GestionEquipos, GestionProyectos, GestionParticipantes, GestionMentores, SistemaChat}

  @moduletag :performance
  @moduletag timeout: 120_000

  setup do
    # Limpiar datos antes de cada prueba
    File.rm_rf("data")
    File.mkdir_p!("data")
    :ok
  end

  describe "Pruebas de Concurrencia - Chat" do
    test "enviar 1000 mensajes concurrentemente" do
      canal = "test_concurrencia"
      num_mensajes = 1000

      IO.puts("\n Iniciando: #{num_mensajes} mensajes concurrentes...")

      inicio = System.monotonic_time(:millisecond)

      # Crear 1000 tareas que envían mensajes simultáneamente
      tareas = Enum.map(1..num_mensajes, fn i ->
        Task.async(fn ->
          SistemaChat.enviar_mensaje("usuario_#{i}", "Mensaje #{i}", canal)
        end)
      end)

      # Esperar a que todas completen
      resultados = Enum.map(tareas, &Task.await(&1, 10_000))

      fin = System.monotonic_time(:millisecond)
      tiempo_total = fin - inicio

      # Contar éxitos
      exitosos = Enum.count(resultados, fn
        {:ok, _} -> true
        _ -> false
      end)

      # Verificar historial
      {:ok, mensajes} = SistemaChat.obtener_historial(canal)

      # Reporte detallado
      IO.puts("\n═══════════════════════════════════════════")
      IO.puts("   PRUEBA COMPLETADA: Chat - #{num_mensajes} mensajes")
      IO.puts("═══════════════════════════════════════════")
      IO.puts("   Mensajes enviados: #{exitosos}/#{num_mensajes}")
      IO.puts("   Tiempo total: #{tiempo_total}ms")
      IO.puts("   Promedio: #{Float.round(tiempo_total / num_mensajes, 2)}ms/mensaje")
      IO.puts("   Throughput: #{Float.round(num_mensajes / (tiempo_total / 1000), 2)} msg/seg")
      IO.puts("═══════════════════════════════════════════\n")

      # Assertions
      assert exitosos >= num_mensajes * 0.9, "Al menos 90% de mensajes deben enviarse"
      assert length(mensajes) >= num_mensajes * 0.9, "Al menos 90% deben persistirse"
    end

    test "multiples usuarios en multiples canales concurrentemente" do
      num_usuarios = 100
      num_canales = 10
      mensajes_por_usuario = 10

      IO.puts("\n Iniciando: #{num_usuarios} usuarios, #{num_canales} canales...")

      inicio = System.monotonic_time(:millisecond)

      tareas = for usuario <- 1..num_usuarios,
                   canal <- 1..num_canales do
        Task.async(fn ->
          Enum.each(1..mensajes_por_usuario, fn msg ->
            SistemaChat.enviar_mensaje(
              "user_#{usuario}",
              "Msg #{msg}",
              "canal_#{canal}"
            )
          end)
        end)
      end

      Enum.each(tareas, &Task.await(&1, 30_000))

      fin = System.monotonic_time(:millisecond)
      tiempo_total = fin - inicio
      total_mensajes = num_usuarios * num_canales * mensajes_por_usuario

      IO.puts("\n═══════════════════════════════════════════")
      IO.puts("   PRUEBA COMPLETADA: Multiples canales")
      IO.puts("═══════════════════════════════════════════")
      IO.puts("   Total mensajes: #{total_mensajes}")
      IO.puts("   Canales: #{num_canales}")
      IO.puts("   Usuarios: #{num_usuarios}")
      IO.puts("   Tiempo: #{tiempo_total}ms")
      IO.puts("   Throughput: #{Float.round(total_mensajes / (tiempo_total / 1000), 2)} msg/seg")
      IO.puts("═══════════════════════════════════════════\n")

      assert tiempo_total < 30_000, "Debe completar en menos de 30 segundos"
    end
  end

  describe "Pruebas de Concurrencia - Equipos" do
    test "crear 100 equipos concurrentemente" do
      num_equipos = 100

      IO.puts("\n Creando #{num_equipos} equipos concurrentemente...")

      inicio = System.monotonic_time(:millisecond)

      tareas = Enum.map(1..num_equipos, fn i ->
        Task.async(fn ->
          GestionEquipos.crear_equipo(%{
            nombre: "Equipo #{i}",
            tema: "Tema #{i}",
            categoria: Enum.random([:tecnologia, :salud, :educativo])
          })
        end)
      end)

      resultados = Enum.map(tareas, &Task.await(&1, 5_000))

      fin = System.monotonic_time(:millisecond)
      tiempo_total = fin - inicio

      exitosos = Enum.count(resultados, fn
        {:ok, _} -> true
        _ -> false
      end)

      {:ok, equipos} = GestionEquipos.listar_equipos()

      IO.puts("\n═══════════════════════════════════════════")
      IO.puts("  PRUEBA COMPLETADA: Creacion de equipos")
      IO.puts("═══════════════════════════════════════════")
      IO.puts("   Equipos creados: #{exitosos}/#{num_equipos}")
      IO.puts("   Persistidos: #{length(equipos)}")
      IO.puts("   Tiempo total: #{tiempo_total}ms")
      IO.puts("   Promedio: #{Float.round(tiempo_total / num_equipos, 2)}ms/equipo")
      IO.puts("═══════════════════════════════════════════\n")

      assert exitosos >= num_equipos * 0.95
      assert length(equipos) >= num_equipos * 0.95
    end
  end

  describe "Pruebas de Concurrencia - Proyectos" do
    test "crear y actualizar proyectos concurrentemente" do
      # Primero crear equipos
      equipos = Enum.map(1..50, fn i ->
        {:ok, equipo} = GestionEquipos.crear_equipo(%{
          nombre: "Team #{i}",
          tema: "Test",
          categoria: :tecnologia
        })
        equipo
      end)

      IO.puts("\n Creando 50 proyectos y agregando avances...")

      inicio = System.monotonic_time(:millisecond)

      # Crear proyectos
      tareas_proyectos = Enum.map(equipos, fn equipo ->
        Task.async(fn ->
          GestionProyectos.registrar_proyecto(%{
            nombre: "Proyecto #{equipo.nombre}",
            descripcion: "Descripcion detallada del proyecto de innovacion tecnologica",
            categoria: :tecnologia,
            equipo_id: equipo.id
          })
        end)
      end)

      proyectos = Enum.map(tareas_proyectos, &Task.await(&1, 5_000))
      |> Enum.filter(fn
        {:ok, _} -> true
        _ -> false
      end)
      |> Enum.map(fn {:ok, p} -> p end)

      # Agregar avances de forma secuencial por proyecto
      Enum.each(proyectos, fn proyecto ->
        Enum.each(1..5, fn i ->
          GestionProyectos.agregar_avance(proyecto.id, "Avance #{i}")
        end)
      end)

      fin = System.monotonic_time(:millisecond)
      tiempo_total = fin - inicio

      {:ok, proyectos_finales} = GestionProyectos.listar_proyectos()
      total_avances = Enum.reduce(proyectos_finales, 0, fn p, acc ->
        acc + length(p.avances)
      end)

      IO.puts("\n═══════════════════════════════════════════")
      IO.puts("   PRUEBA COMPLETADA: Proyectos y avances")
      IO.puts("═══════════════════════════════════════════")
      IO.puts("   Proyectos creados: #{length(proyectos)}")
      IO.puts("   Total avances: #{total_avances}")
      IO.puts("   Tiempo total: #{tiempo_total}ms")
      IO.puts("═══════════════════════════════════════════\n")

      assert length(proyectos) >= 45
      assert total_avances >= 200
    end
  end

  describe "Pruebas de Concurrencia - Participantes" do
    test "registrar 200 participantes concurrentemente" do
      num_participantes = 200

      IO.puts("\n Registrando #{num_participantes} participantes...")

      inicio = System.monotonic_time(:millisecond)

      tareas = Enum.map(1..num_participantes, fn i ->
        Task.async(fn ->
          GestionParticipantes.registrar_participante(%{
            nombre: "Participante #{i}",
            correo: "user#{i}@test.com",
            habilidades: ["Elixir", "Testing"],
            password: "pass123"
          })
        end)
      end)

      resultados = Enum.map(tareas, &Task.await(&1, 10_000))

      fin = System.monotonic_time(:millisecond)
      tiempo_total = fin - inicio

      exitosos = Enum.count(resultados, fn
        {:ok, _} -> true
        _ -> false
      end)

      {:ok, participantes} = GestionParticipantes.listar_participantes()

      IO.puts("\n═══════════════════════════════════════════")
      IO.puts("   PRUEBA COMPLETADA: Registro participantes")
      IO.puts("═══════════════════════════════════════════")
      IO.puts("   Registrados: #{exitosos}/#{num_participantes}")
      IO.puts("   Persistidos: #{length(participantes)}")
      IO.puts("   Tiempo total: #{tiempo_total}ms")
      IO.puts("   Promedio: #{Float.round(tiempo_total / num_participantes, 2)}ms/usuario")
      IO.puts("═══════════════════════════════════════════\n")

      assert exitosos >= num_participantes * 0.95
    end
  end

  describe "Pruebas de Carga - Sistema Completo" do
    test "simulacion de hackathon completa con 50 equipos" do
      IO.puts("\n SIMULACION COMPLETA DE HACKATHON")
      IO.puts("════════════════════════════════════════════\n")

      inicio_total = System.monotonic_time(:millisecond)

      # Fase 1: Registro
      IO.puts(" Fase 1: Registrando participantes y mentores...")
      participantes = Enum.map(1..150, fn i ->
        {:ok, p} = GestionParticipantes.registrar_participante(%{
          nombre: "User #{i}",
          correo: "u#{i}@test.com",
          habilidades: ["Tech"],
          password: "pass123"
        })
        p
      end)

      mentores = Enum.map(1..10, fn i ->
        {:ok, m} = GestionMentores.registrar_mentor(%{
          nombre: "Mentor #{i}",
          correo: "m#{i}@test.com",
          especialidad: "Tech",
          password: "pass123"
        })
        m
      end)
      IO.puts("    #{length(participantes)} participantes y #{length(mentores)} mentores")

      # Fase 2: Equipos
      IO.puts("\n Fase 2: Creando equipos...")
      equipos = Enum.map(1..50, fn i ->
        {:ok, e} = GestionEquipos.crear_equipo(%{
          nombre: "Team #{i}",
          tema: "Project #{i}",
          categoria: Enum.random([:tecnologia, :salud, :educativo])
        })
        e
      end)
      IO.puts("    #{length(equipos)} equipos creados")

      # Fase 3: Asignar participantes
      IO.puts("\n Fase 3: Asignando participantes a equipos...")
      Enum.each(participantes, fn p ->
        equipo = Enum.random(equipos)
        GestionParticipantes.unirse_a_equipo(p.id, equipo.id)
      end)
      IO.puts("    Participantes asignados")

      # Verificaciones basicas
      {:ok, equipos_final} = GestionEquipos.listar_equipos()
      {:ok, participantes_final} = GestionParticipantes.listar_participantes()

      fin_total = System.monotonic_time(:millisecond)
      tiempo_total = fin_total - inicio_total

      IO.puts("\n════════════════════════════════════════════")
      IO.puts("   FASE 1-3 COMPLETADA")
      IO.puts("════════════════════════════════════════════")
      IO.puts("  Participantes: #{length(participantes_final)}")
      IO.puts("  Mentores: #{length(mentores)}")
      IO.puts("  Equipos: #{length(equipos_final)}")
      IO.puts("  Tiempo: #{Float.round(tiempo_total / 1000, 2)}s")
      IO.puts("════════════════════════════════════════════\n")

      # Assertions basicas
      assert length(equipos_final) >= 45
      assert length(participantes_final) >= 140
    end
  end
end
