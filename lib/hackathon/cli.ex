defmodule Hackathon.CLI do
@moduledoc """
Interfaz de línea de comandos mejorada con menú jerárquico
"""

alias Hackathon.Services.{GestionEquipos, GestionProyectos, GestionParticipantes, GestionMentores, SistemaChat}
alias Hackathon.Semilla

@password_acceso "ingreso123"

def main(_args \\ []) do
mostrar_banner()
cargar_datos_iniciales()
menu_principal()
end

defp mostrar_banner do
IO.puts("\n")
IO.puts("===============================================")
IO.puts(" ")
IO.puts(" HACKATHON CODE4FUTURE 2025 ")
IO.puts(" ")
IO.puts(" Sistema de Gestion de Hackathon ")
IO.puts(" ")
IO.puts("===============================================")
IO.puts("\n")
end

defp cargar_datos_iniciales do
IO.puts("Cargando datos de la hackathon...")
{:ok, _} = Semilla.cargar_datos()
IO.puts("Datos cargados exitosamente\n")
:timer.sleep(1000)
end

# ============================================
# MENÚ PRINCIPAL (6 OPCIONES)
# ============================================

defp menu_principal do
mostrar_menu_principal()

case obtener_opcion() do
"1" -> submenu_consultas() |> then(fn _ -> menu_principal() end)
"2" -> submenu_registros() |> then(fn _ -> menu_principal() end)
"3" -> submenu_colaboracion() |> then(fn _ -> menu_principal() end)
"4" -> submenu_eliminacion() |> then(fn _ -> menu_principal() end)
"5" -> submenu_sistema() |> then(fn _ -> menu_principal() end)
"0" -> salir()
_ ->
IO.puts("\nX Opcion invalida. Intente de nuevo.\n")
menu_principal()
end
end

defp mostrar_menu_principal do
IO.puts("\n")
IO.puts("=============== MENU PRINCIPAL ================")
IO.puts("")
IO.puts(" 1. CONSULTAS")
IO.puts(" 2. REGISTROS")
IO.puts(" 3. COLABORACION")
IO.puts(" 4. ELIMINACION")
IO.puts(" 5. SISTEMA")
IO.puts("")
IO.puts(" 0. Salir")
IO.puts("")
IO.puts("===============================================")
end

# ============================================
# SUBMENÚ 1: CONSULTAS
# ============================================

defp submenu_consultas do
mostrar_menu_consultas()

case obtener_opcion() do
"1" -> ver_equipos() |> then(fn _ -> submenu_consultas() end)
"2" -> ver_proyectos() |> then(fn _ -> submenu_consultas() end)
"3" -> ver_proyecto_por_equipo() |> then(fn _ -> submenu_consultas() end)
"4" -> ver_proyectos_por_estado() |> then(fn _ -> submenu_consultas() end)
"5" -> ver_participantes_protegido() |> then(fn _ -> submenu_consultas() end)
"6" -> ver_mentores_protegido() |> then(fn _ -> submenu_consultas() end)
"0" -> :volver_menu_principal
_ ->
IO.puts("\nX Opcion invalida.\n")
submenu_consultas()
end
end

defp mostrar_menu_consultas do
IO.puts("\n")
IO.puts("============== CONSULTAS ===================")
IO.puts("")
IO.puts(" 1. Ver todos los equipos")
IO.puts(" 2. Ver todos los proyectos")
IO.puts(" 3. Buscar proyecto por equipo")
IO.puts(" 4. Filtrar proyectos por estado")
IO.puts(" 5. Ver participantes (requiere acceso)")
IO.puts(" 6. Ver mentores (requiere acceso)")
IO.puts("")
IO.puts(" 0. ← Volver al menu principal")
IO.puts("")
IO.puts("===============================================")
end

# ============================================
# SUBMENÚ 2: REGISTROS
# ============================================

defp submenu_registros do
mostrar_menu_registros()

case obtener_opcion() do
"1" -> registrar_participante() |> then(fn _ -> submenu_registros() end)
"2" -> unirse_equipo() |> then(fn _ -> submenu_registros() end)
"3" -> crear_equipo() |> then(fn _ -> submenu_registros() end)
"4" -> crear_proyecto() |> then(fn _ -> submenu_registros() end)
"5" -> registrar_mentor() |> then(fn _ -> submenu_registros() end)
"6" -> asignar_mentor_equipo() |> then(fn _ -> submenu_registros() end)
"7" -> cambiar_estado_proyecto() |> then(fn _ -> submenu_registros() end)
"0" -> :volver_menu_principal
_ ->
IO.puts("\nX Opcion invalida.\n")
submenu_registros()
end
end

defp mostrar_menu_registros do
IO.puts("\n")
IO.puts("============== REGISTROS ==================")
IO.puts("")
IO.puts(" 1. Registrar nuevo participante")
IO.puts(" 2. Unirse a un equipo")
IO.puts(" 3. Crear nuevo equipo")
IO.puts(" 4. Crear nuevo proyecto")
IO.puts(" 5. Registrar nuevo mentor")
IO.puts(" 6. Asignar mentor a equipo")
IO.puts(" 7. Cambiar estado de proyecto")
IO.puts("")
IO.puts(" 0. ← Volver al menu principal")
IO.puts("")
IO.puts("===============================================")
end

# ============================================
# SUBMENÚ 3: COLABORACIÓN
# ============================================

defp submenu_colaboracion do
  mostrar_menu_colaboracion()

  case obtener_opcion() do
    "1" -> agregar_avance() |> then(fn _ -> submenu_colaboracion() end)
    "2" -> ver_chat_equipo() |> then(fn _ -> submenu_colaboracion() end)
    "3" -> enviar_mensaje_chat() |> then(fn _ -> submenu_colaboracion() end)
    "4" -> ver_canal_general() |> then(fn _ -> submenu_colaboracion() end)
    "5" -> enviar_anuncio_general() |> then(fn _ -> submenu_colaboracion() end)
    "6" -> dar_retroalimentacion_mentor() |> then(fn _ -> submenu_colaboracion() end)
    "7" -> gestionar_salas_tematicas() |> then(fn _ -> submenu_colaboracion() end)
    "8" -> ver_metricas_sistema() |> then(fn _ -> submenu_colaboracion() end)
    "0" -> :volver_menu_principal
    _ ->
      IO.puts("\nX Opcion invalida.\n")
      submenu_colaboracion()
  end
end

defp submenu_nodos_distribuidos do
  mostrar_menu_nodos()

  case obtener_opcion() do
    "1" -> ver_cluster_status() |> then(fn _ -> submenu_nodos_distribuidos() end)
    "2" -> conectar_nodo_manual() |> then(fn _ -> submenu_nodos_distribuidos() end)
    "3" -> desconectar_nodo() |> then(fn _ -> submenu_nodos_distribuidos() end)
    "4" -> sincronizar_cluster() |> then(fn _ -> submenu_nodos_distribuidos() end)
    "5" -> enviar_broadcast_manual() |> then(fn _ -> submenu_nodos_distribuidos() end)
    "6" -> dashboard_en_vivo() |> then(fn _ -> submenu_nodos_distribuidos() end)
    "7" -> configurar_autoreconexion() |> then(fn _ -> submenu_nodos_distribuidos() end)
    "8" -> estadisticas_cluster() |> then(fn _ -> submenu_nodos_distribuidos() end)
    "0" -> :volver_menu_principal
    _ ->
      IO.puts("\nX Opcion invalida.\n")
      submenu_nodos_distribuidos()
  end
end

defp mostrar_menu_nodos do
  IO.puts("\n")
  IO.puts("============ CLUSTER DISTRIBUIDO ==========")
  IO.puts("")
  IO.puts(" 1. Ver estado del cluster")
  IO.puts(" 2. Conectar a un nodo")
  IO.puts(" 3. Desconectar nodo")
  IO.puts(" 4. Sincronizar cluster completo")
  IO.puts(" 5. Enviar broadcast")
  IO.puts(" 6. Dashboard en tiempo real")
  IO.puts(" 7. Configurar auto-reconexión")
  IO.puts(" 8. Estadísticas del cluster")
  IO.puts("")
  IO.puts(" 0. ← Volver al menú principal")
  IO.puts("")
  IO.puts("===============================================")
end

defp ver_cluster_status do
  IO.puts("\n")
  IO.puts("═══════════════════════════════════════════")
  IO.puts("   ESTADO DEL CLUSTER DISTRIBUIDO")
  IO.puts("═══════════════════════════════════════════")
  IO.puts("")

  # Información del nodo actual
  info = Hackathon.Distribucion.Nodo.info_nodo_actual()

  IO.puts(" Nodo Actual:")
  IO.puts("   Nombre: #{info.nombre}")
  IO.puts("   Cookie: #{info.cookie}")
  IO.puts("   Vivo: #{if info.vivo?, do: " Sí", else: " No"}")
  IO.puts("")

  # Nodos conectados
  case Hackathon.Distribucion.Nodo.listar_nodos_conectados() do
    {:ok, nodos_info} ->
      IO.puts(" Nodos Conectados: #{nodos_info.total}")

      if nodos_info.total > 0 do
        IO.puts("")
        Enum.with_index(nodos_info.conectados, 1)
        |> Enum.each(fn {nodo, idx} ->
          estado = if Node.ping(nodo) == :pong, do: "Ok", else: "Desconectado"
          IO.puts("   #{idx}. #{estado} #{nodo}")
        end)
      else
        IO.puts("   (No hay otros nodos conectados)")
      end
      IO.puts("")

      # Nodos conocidos pero no conectados
      conocidos_no_conectados = nodos_info.conocidos -- nodos_info.conectados
      if length(conocidos_no_conectados) > 0 do
        IO.puts("  Nodos Conocidos (desconectados):")
        Enum.each(conocidos_no_conectados, fn nodo ->
          IO.puts("    #{nodo}")
        end)
        IO.puts("")
      end

    _ ->
      IO.puts(" Error al obtener información de nodos\n")
  end

  IO.puts("═══════════════════════════════════════════\n")
  pausar()
end

defp conectar_nodo_manual do
  IO.puts("\n=== CONECTAR A UN NODO ===\n")

  IO.puts("Ejemplos de formato:")
  IO.puts("  • Mismo host: nodo1@#{:inet.gethostname() |> elem(1)}")
  IO.puts("  • Otra PC: nodo1@192.168.1.10")
  IO.puts("")

  IO.puts("Ingresa el nombre completo del nodo:")
  entrada = IO.gets("> ") |> String.trim()

  if entrada != "" do
    nodo = String.to_atom(entrada)

    IO.puts("\n Conectando a #{nodo}...")

    case Hackathon.Distribucion.Nodo.conectar_nodo(nodo) do
      {:ok, :conectado} ->
        IO.puts(" Conectado exitosamente!")

        # Preguntar si activar auto-reconexión
        IO.puts("\n¿Activar auto-reconexión para este nodo? (s/n)")
        if IO.gets("> ") |> String.trim() |> String.downcase() == "s" do
          Hackathon.Distribucion.AutoReconexion.activar_para(nodo)
          IO.puts(" Auto-reconexión activada")
        end

      {:ok, :ya_conectado} ->
        IO.puts("  El nodo ya estaba conectado")

      {:error, :conexion_fallida} ->
        IO.puts(" No se pudo conectar")
        IO.puts("\nVerifica que:")
        IO.puts("  • El nodo esté ejecutándose")
        IO.puts("  • Usen la misma cookie")
        IO.puts("  • El firewall permita la conexión")

      error ->
        IO.puts(" Error: #{inspect(error)}")
    end
  else
    IO.puts("\nOperación cancelada")
  end

  IO.puts("")
  pausar()
end

defp desconectar_nodo do
  IO.puts("\n=== DESCONECTAR NODO ===\n")

  case Hackathon.Distribucion.Nodo.listar_nodos_conectados() do
    {:ok, %{conectados: []}} ->
      IO.puts("No hay nodos conectados para desconectar.\n")

    {:ok, %{conectados: nodos}} ->
      IO.puts("Nodos conectados:\n")

      nodos
      |> Enum.with_index(1)
      |> Enum.each(fn {nodo, idx} ->
        IO.puts("  #{idx}. #{nodo}")
      end)

      IO.puts("\nSelecciona el número del nodo a desconectar (0 para cancelar):")
      opcion = IO.gets("> ") |> String.trim()

      case Integer.parse(opcion) do
        {num, _} when num > 0 and num <= length(nodos) ->
          nodo = Enum.at(nodos, num - 1)

          if Node.disconnect(nodo) do
            IO.puts("\n Desconectado de #{nodo}")
          else
            IO.puts("\n No se pudo desconectar")
          end

        {0, _} ->
          IO.puts("\nOperación cancelada")

        _ ->
          IO.puts("\n Opción inválida")
      end

    _ ->
      IO.puts("Error al listar nodos.\n")
  end

  pausar()
end

defp sincronizar_cluster do
  IO.puts("\n=== SINCRONIZAR CLUSTER COMPLETO ===\n")

  case Hackathon.Distribucion.Nodo.listar_nodos_conectados() do
    {:ok, %{total: 0}} ->
      IO.puts("  No hay otros nodos conectados para sincronizar.\n")

    {:ok, %{total: total}} ->
      IO.puts(" Sincronizando con #{total} nodo(s)...")

      Hackathon.Distribucion.Nodo.sincronizar_datos()

      # Esperar un poco
      :timer.sleep(1000)

      IO.puts(" Sincronización completada!")
      IO.puts("\nDatos sincronizados:")
      IO.puts("  • Equipos")
      IO.puts("  • Proyectos")
      IO.puts("  • Participantes")
      IO.puts("  • Mentores\n")

    _ ->
      IO.puts(" Error al sincronizar\n")
  end

  pausar()
end

defp enviar_broadcast_manual do
  IO.puts("\n=== ENVIAR BROADCAST A TODOS LOS NODOS ===\n")

  case Hackathon.Distribucion.Nodo.listar_nodos_conectados() do
    {:ok, %{total: 0}} ->
      IO.puts("  No hay otros nodos conectados.\n")

    {:ok, %{total: total}} ->
      IO.puts("Destino: #{total} nodo(s) conectado(s)")
      IO.puts("\nTipo de mensaje:")
      IO.puts("  1. Anuncio general")
      IO.puts("  2. Alerta")
      IO.puts("  3. Notificación de evento")
      IO.puts("  4. Mensaje personalizado")

      tipo_opcion = IO.gets("\nSelecciona tipo: ") |> String.trim()

      {tipo, contenido} = case tipo_opcion do
        "1" ->
          IO.puts("\nEscribe el anuncio:")
          texto = IO.gets("> ") |> String.trim()
          {:anuncio, texto}

        "2" ->
          IO.puts("\nEscribe la alerta:")
          texto = IO.gets("> ") |> String.trim()
          {:alerta, texto}

        "3" ->
          IO.puts("\nDescribe el evento:")
          texto = IO.gets("> ") |> String.trim()
          {:evento, texto}

        "4" ->
          IO.puts("\nEscribe el mensaje:")
          texto = IO.gets("> ") |> String.trim()
          {:custom, texto}

        _ ->
          {:none, nil}
      end

      if contenido do
        mensaje = {tipo, contenido, Node.self(), DateTime.utc_now()}
        Hackathon.Distribucion.Nodo.broadcast(mensaje)
        IO.puts("\n Broadcast enviado a #{total} nodo(s)\n")
      else
        IO.puts("\nOperación cancelada\n")
      end

    _ ->
      IO.puts(" Error al enviar broadcast\n")
  end

  pausar()
end

defp dashboard_en_vivo do
  IO.puts("\n=== DASHBOARD EN TIEMPO REAL ===\n")
  IO.puts("El dashboard se actualizará cada 5 segundos.")
  IO.puts("Presiona Ctrl+C dos veces para salir.\n")

  pausar()

  # Iniciar dashboard
  Hackathon.Distribucion.Dashboard.iniciar_monitoreo(5)

  # Mantener proceso vivo
  Process.sleep(:infinity)
end

defp configurar_autoreconexion do
  IO.puts("\n=== CONFIGURAR AUTO-RECONEXIÓN ===\n")

  IO.puts("Opciones:")
  IO.puts("  1. Activar para todos los nodos conectados")
  IO.puts("  2. Activar para un nodo específico")
  IO.puts("  3. Desactivar auto-reconexión")
  IO.puts("  4. Ver nodos monitoreados")

  opcion = IO.gets("\n> ") |> String.trim()

  case opcion do
    "1" ->
      nodos = Node.list()
      if length(nodos) > 0 do
        Enum.each(nodos, fn nodo ->
          Hackathon.Distribucion.AutoReconexion.activar_para(nodo)
        end)
        IO.puts("\n Auto-reconexión activada para #{length(nodos)} nodo(s)\n")
      else
        IO.puts("\n  No hay nodos conectados\n")
      end

    "2" ->
      IO.puts("\nIngresa el nodo (ej: nodo1@192.168.1.10):")
      nodo = IO.gets("> ") |> String.trim() |> String.to_atom()
      Hackathon.Distribucion.AutoReconexion.activar_para(nodo)
      IO.puts("\n Auto-reconexión activada para #{nodo}\n")

    "3" ->
      monitoreados = Hackathon.Distribucion.AutoReconexion.nodos_monitoreados()
      if length(monitoreados) > 0 do
        IO.puts("\nNodos monitoreados:")
        Enum.with_index(monitoreados, 1)
        |> Enum.each(fn {nodo, idx} ->
          IO.puts("  #{idx}. #{nodo}")
        end)

        IO.puts("\nSelecciona el nodo:")
        num = IO.gets("> ") |> String.trim() |> String.to_integer()
        nodo = Enum.at(monitoreados, num - 1)
        Hackathon.Distribucion.AutoReconexion.desactivar_para(nodo)
        IO.puts("\n Auto-reconexión desactivada para #{nodo}\n")
      else
        IO.puts("\n  No hay nodos monitoreados\n")
      end

    "4" ->
      monitoreados = Hackathon.Distribucion.AutoReconexion.nodos_monitoreados()
      IO.puts("\n📡 Nodos con auto-reconexión:")
      if length(monitoreados) > 0 do
        Enum.each(monitoreados, fn nodo ->
          estado = if nodo in Node.list(), do: " Conectado", else: " Reconectando"
          IO.puts("  • #{nodo} - #{estado}")
        end)
      else
        IO.puts("  (Ninguno)")
      end
      IO.puts("")

    _ ->
      IO.puts("\n Opción inválida\n")
  end

  pausar()
end

defp estadisticas_cluster do
  IO.puts("\n")
  IO.puts("═══════════════════════════════════════════")
  IO.puts("   ESTADÍSTICAS DEL CLUSTER")
  IO.puts("═══════════════════════════════════════════")
  IO.puts("")

  case Hackathon.Distribucion.Dashboard.obtener_estadisticas() do
    stats ->
      IO.puts(" CONECTIVIDAD:")
      IO.puts("   Nodos activos: #{stats.total_nodos}")
      IO.puts("   Nodo actual: #{stats.nodo_actual}")
      IO.puts("")

      IO.puts(" DATOS:")
      IO.puts("   Equipos totales: #{stats.equipos_total}")
      IO.puts("   Proyectos totales: #{stats.proyectos_total}")
      IO.puts("   Participantes: #{stats.participantes_total}")
      IO.puts("   Mentores: #{stats.mentores_total}")
      IO.puts("   Mensajes: #{stats.mensajes_total}")
      IO.puts("")

      IO.puts(" RECURSOS:")
      IO.puts("   Memoria total: #{stats.memoria_total_mb} MB")
      IO.puts("")

      # Estadísticas de auto-reconexión
      auto_stats = Hackathon.Distribucion.AutoReconexion.estadisticas()
      IO.puts(" AUTO-RECONEXIÓN:")
      IO.puts("   Nodos monitoreados: #{auto_stats.nodos_monitoreados}")
      IO.puts("   Reconexiones exitosas: #{auto_stats.reconexiones_exitosas}")
      IO.puts("   Reconexiones fallidas: #{auto_stats.reconexiones_fallidas}")
      if length(auto_stats.nodos_perdidos) > 0 do
        IO.puts("   Nodos perdidos: #{Enum.join(auto_stats.nodos_perdidos, ", ")}")
      end
      IO.puts("")

    _ ->
      IO.puts(" Error al obtener estadísticas\n")
  end

  IO.puts("═══════════════════════════════════════════\n")
  pausar()
end

defp mostrar_menu_colaboracion do
  IO.puts("\n")
  IO.puts("============ COLABORACION ==================")
  IO.puts("")
  IO.puts(" 1. Agregar avance a proyecto")
  IO.puts(" 2. Ver chat de equipo")
  IO.puts(" 3. Enviar mensaje a equipo")
  IO.puts(" 4. Ver canal general de anuncios")
  IO.puts(" 5. Enviar anuncio general (mentor)")
  IO.puts(" 6. Dar retroalimentacion (mentor)")
  IO.puts(" 7. Gestionar salas tematicas")
  IO.puts(" 8. Ver metricas del sistema")
  IO.puts("")
  IO.puts(" 0. ← Volver al menu principal")
  IO.puts("")
  IO.puts("===============================================")
end
# ============================================
# SUBMENÚ 4: ELIMINACIÓN
# ============================================

defp submenu_eliminacion do
mostrar_menu_eliminacion()

case obtener_opcion() do
"1" -> eliminar_participante() |> then(fn _ -> submenu_eliminacion() end)
"2" -> eliminar_mentor() |> then(fn _ -> submenu_eliminacion() end)
"3" -> eliminar_equipo() |> then(fn _ -> submenu_eliminacion() end)
"4" -> eliminar_proyecto() |> then(fn _ -> submenu_eliminacion() end)
"0" -> :volver_menu_principal
_ ->
IO.puts("\nX Opcion invalida.\n")
submenu_eliminacion()
end
end

defp mostrar_menu_eliminacion do
IO.puts("\n")
IO.puts("============ ELIMINACION ==================")
IO.puts("")
IO.puts(" 1. Eliminar participante (requiere acceso)")
IO.puts(" 2. Eliminar mentor (requiere acceso)")
IO.puts(" 3. Eliminar equipo")
IO.puts(" 4. Eliminar proyecto")
IO.puts("")
IO.puts(" 0. ← Volver al menu principal")
IO.puts("")
IO.puts("===============================================")
end

# ============================================
# SUBMENÚ 5: SISTEMA
# ============================================

defp submenu_sistema do
mostrar_menu_sistema()

case obtener_opcion() do
"1" -> mostrar_ayuda() |> then(fn _ -> submenu_sistema() end)
"2" -> recargar_datos() |> then(fn _ -> submenu_sistema() end)
"0" -> :volver_menu_principal
_ ->
IO.puts("\nX Opcion invalida.\n")
submenu_sistema()
end
end

defp mostrar_menu_sistema do
IO.puts("\n")
IO.puts("============== SISTEMA ====================")
IO.puts("")
IO.puts(" 1. Ayuda (/help)")
IO.puts(" 2. Recargar datos")
IO.puts("")
IO.puts(" 0. ← Volver al menu principal")
IO.puts("")
IO.puts("===============================================")
end

# ============================================
# FUNCIONES AUXILIARES
# ============================================

defp obtener_opcion do
IO.gets("\nSeleccione una opcion: ")
|> String.trim()
end

# ============================================
# FUNCIONES DE SEGURIDAD
# ============================================

defp verificar_acceso_admin do
IO.puts("\n=== ACCESO RESTRINGIDO ===")
IO.puts("Ingrese la contraseña de acceso:")
password = IO.gets("> ") |> String.trim()

if password == @password_acceso do
{:ok, :autorizado}
else
IO.puts("\nX Contraseña incorrecta\n")
{:error, :no_autorizado}
end
end

defp ver_participantes_protegido do
case verificar_acceso_admin() do
{:ok, :autorizado} -> ver_participantes()
{:error, :no_autorizado} -> pausar()
end
end

defp ver_mentores_protegido do
case verificar_acceso_admin() do
{:ok, :autorizado} -> ver_mentores()
{:error, :no_autorizado} -> pausar()
end
end

# ============================================
# FUNCIONES DE CONSULTA
# ============================================

defp ver_equipos do
IO.puts("\n")
IO.puts("===============================================")
IO.puts(" EQUIPOS REGISTRADOS ")
IO.puts("===============================================")
IO.puts("")

case GestionEquipos.listar_equipos() do
{:ok, []} ->
IO.puts(" No hay equipos registrados.\n")

{:ok, equipos} ->
equipos
|> Enum.with_index(1)
|> Enum.each(fn {equipo, index} ->
IO.puts(" #{index}. #{equipo.nombre}")
IO.puts(" Tema: #{equipo.tema}")
IO.puts(" Categoria: #{equipo.categoria}")
IO.puts(" Miembros: #{length(equipo.miembros)}/#{equipo.max_miembros}")
IO.puts(" Estado: #{if equipo.activo, do: "Activo", else: "Inactivo"}")
IO.puts("")
end)

_ ->
IO.puts(" Error al listar equipos\n")
end

pausar()
end

defp ver_proyectos do
IO.puts("\n")
IO.puts("===============================================")
IO.puts(" PROYECTOS DE LA HACKATHON ")
IO.puts("===============================================")
IO.puts("")

case GestionProyectos.listar_proyectos() do
{:ok, []} ->
IO.puts(" No hay proyectos registrados.\n")

{:ok, proyectos} ->
proyectos
|> Enum.with_index(1)
|> Enum.each(fn {proyecto, index} ->
mostrar_proyecto_detallado(proyecto, index)
end)

_ ->
IO.puts(" Error al listar proyectos\n")
end

pausar()
end

defp ver_proyecto_por_equipo do
IO.puts("\n=== BUSCAR PROYECTO POR EQUIPO ===\n")
IO.puts("Ingrese el nombre del equipo:")
nombre = IO.gets("> ") |> String.trim()

case GestionEquipos.buscar_por_nombre(nombre) do
{:ok, equipo} ->
IO.puts("\nEquipo encontrado: #{equipo.nombre}\n")

case GestionProyectos.obtener_por_equipo(equipo.id) do
{:ok, proyecto} ->
mostrar_proyecto_detallado(proyecto, 1)

{:error, :no_encontrado} ->
IO.puts("Este equipo aun no tiene un proyecto registrado.\n")

_ ->
IO.puts("Error al buscar proyecto\n")
end

{:error, :no_encontrado} ->
IO.puts("\nEquipo '#{nombre}' no encontrado.\n")

_ ->
IO.puts("\nError al buscar equipo\n")
end

pausar()
end

defp ver_proyectos_por_estado do
IO.puts("\n=== FILTRAR PROYECTOS POR ESTADO ===\n")
IO.puts("Seleccione el estado:")
IO.puts(" 1. Iniciado")
IO.puts(" 2. En Progreso")
IO.puts(" 3. Finalizado")
IO.puts(" 4. Presentado")

opcion = IO.gets("\n> ") |> String.trim()

estado = case opcion do
"1" -> :iniciado
"2" -> :en_progreso
"3" -> :finalizado
"4" -> :presentado
_ -> nil
end

if estado do
case GestionProyectos.consultar_por_estado(estado) do
{:ok, proyectos} ->
IO.puts("\n=== Proyectos en estado: #{estado} ===\n")

if Enum.empty?(proyectos) do
IO.puts("No hay proyectos en este estado.\n")
else
Enum.with_index(proyectos, 1)
|> Enum.each(fn {proyecto, index} ->
IO.puts("#{index}. #{proyecto.nombre}")
IO.puts(" Categoria: #{proyecto.categoria}")
IO.puts(" Avances: #{length(proyecto.avances)}")
IO.puts("")
end)
end

_ ->
IO.puts("\nError al consultar proyectos\n")
end
else
IO.puts("\nOpcion invalida.\n")
end

pausar()
end

defp ver_participantes do
IO.puts("\n")
IO.puts("===============================================")
IO.puts(" PARTICIPANTES REGISTRADOS ")
IO.puts("===============================================")
IO.puts("")

case GestionParticipantes.listar_participantes() do
{:ok, []} ->
IO.puts(" No hay participantes registrados.\n")

{:ok, participantes} ->
participantes
|> Enum.with_index(1)
|> Enum.each(fn {participante, index} ->
IO.puts(" #{index}. #{participante.nombre}")
IO.puts(" Email: #{participante.correo}")
IO.puts(" Habilidades: #{Enum.join(participante.habilidades, ", ")}")

estado = case participante.equipo_id do
nil -> "Sin equipo asignado"
equipo_id ->
case GestionEquipos.obtener_equipo(equipo_id) do
{:ok, equipo} -> "Equipo: #{equipo.nombre}"
_ -> "Equipo: #{equipo_id}"
end
end

IO.puts(" Estado: #{estado}")
IO.puts("")
end)

_ ->
IO.puts(" Error al listar participantes\n")
end

pausar()
end

defp ver_mentores do
IO.puts("\n")
IO.puts("===============================================")
IO.puts(" MENTORES REGISTRADOS ")
IO.puts("===============================================")
IO.puts("")

case GestionMentores.listar_mentores() do
{:ok, []} ->
IO.puts(" No hay mentores registrados.\n")

{:ok, mentores} ->
mentores
|> Enum.with_index(1)
|> Enum.each(fn {mentor, index} ->
IO.puts(" #{index}. #{mentor.nombre}")
IO.puts(" Especialidad: #{mentor.especialidad}")
IO.puts(" Email: #{mentor.correo}")
IO.puts(" Equipos asignados: #{length(mentor.equipos_asignados)}/#{mentor.max_equipos}")

if length(mentor.equipos_asignados) > 0 do
IO.puts(" Equipos:")
Enum.each(mentor.equipos_asignados, fn equipo_id ->
case GestionEquipos.obtener_equipo(equipo_id) do
{:ok, equipo} -> IO.puts(" • #{equipo.nombre}")
_ -> IO.puts(" • ID: #{equipo_id}")
end
end)
end

IO.puts(" Disponible: #{if mentor.disponible, do: "Si", else: "No"}")
IO.puts("")
end)

_ ->
IO.puts(" Error al listar mentores\n")
end

pausar()
end

# ============================================
# FUNCIONES DE REGISTRO
# ============================================

defp registrar_participante do
IO.puts("\n=== REGISTRAR NUEVO PARTICIPANTE ===\n")

nombre = IO.gets("Nombre completo: ") |> String.trim()
correo = IO.gets("Correo electronico: ") |> String.trim()

IO.puts("\nHabilidades (separadas por comas):")
IO.puts("Ejemplo: Python, JavaScript, React")
habilidades_str = IO.gets("> ") |> String.trim()

habilidades = if habilidades_str == "" do
[]
else
habilidades_str
|> String.split(",")
|> Enum.map(&String.trim/1)
end

IO.puts("\nCree una contraseña (minimo 6 caracteres):")
password = IO.gets("> ") |> String.trim()

case GestionParticipantes.registrar_participante(%{
nombre: nombre,
correo: correo,
habilidades: habilidades,
password: password
}) do
{:ok, participante} ->
IO.puts("\n+ Participante '#{participante.nombre}' registrado exitosamente!")
IO.puts(" ID: #{participante.id}")
IO.puts(" Correo: #{participante.correo}\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end

pausar()
end

defp registrar_mentor do
IO.puts("\n=== REGISTRAR NUEVO MENTOR ===\n")

nombre = IO.gets("Nombre completo: ") |> String.trim()
correo = IO.gets("Correo electronico: ") |> String.trim()
especialidad = IO.gets("Especialidad: ") |> String.trim()

IO.puts("\nCree una contraseña (minimo 6 caracteres):")
password = IO.gets("> ") |> String.trim()

case GestionMentores.registrar_mentor(%{
nombre: nombre,
correo: correo,
especialidad: especialidad,
password: password
}) do
{:ok, mentor} ->
IO.puts("\n+ Mentor '#{mentor.nombre}' registrado exitosamente!")
IO.puts(" ID: #{mentor.id}")
IO.puts(" Correo: #{mentor.correo}")
IO.puts(" Especialidad: #{mentor.especialidad}\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end

pausar()
end

defp unirse_equipo do
IO.puts("\n=== UNIRSE A UN EQUIPO ===\n")

IO.puts("Ingrese su correo electronico:")
correo = IO.gets("> ") |> String.trim()

case GestionParticipantes.buscar_por_correo(correo) do
{:ok, participante} ->
if participante.equipo_id do
case GestionEquipos.obtener_equipo(participante.equipo_id) do
{:ok, equipo} ->
IO.puts("\nYa perteneces al equipo '#{equipo.nombre}'.\n")
_ ->
IO.puts("\nYa tienes un equipo asignado.\n")
end
else
case GestionEquipos.listar_equipos_activos() do
{:ok, [_|_] = equipos} ->
IO.puts("\nEquipos disponibles:\n")

equipos
|> Enum.with_index(1)
|> Enum.each(fn {equipo, index} ->
espacios = equipo.max_miembros - length(equipo.miembros)
IO.puts(" #{index}. #{equipo.nombre} (#{espacios} espacios disponibles)")
IO.puts(" Tema: #{equipo.tema}")
IO.puts("")
end)

IO.puts("Seleccione el numero del equipo:")
opcion = IO.gets("> ") |> String.trim()

case Integer.parse(opcion) do
{index, _} when index > 0 and index <= length(equipos) ->
equipo = Enum.at(equipos, index - 1)

case GestionParticipantes.unirse_a_equipo(participante.id, equipo.id) do
{:ok, _} ->
IO.puts("\n+ Te has unido exitosamente al equipo '#{equipo.nombre}'!\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end

_ ->
IO.puts("\nOpcion invalida.\n")
end

{:ok, []} ->
IO.puts("\nNo hay equipos disponibles en este momento.\n")

_ ->
IO.puts("\nError al obtener equipos.\n")
end
end

{:error, :no_encontrado} ->
IO.puts("\nParticipante no encontrado con el correo '#{correo}'.")
IO.puts("Registrese primero usando REGISTROS > Opcion 1.\n")

_ ->
IO.puts("\nError al buscar participante.\n")
end

pausar()
end

defp crear_equipo do
IO.puts("\n=== CREAR NUEVO EQUIPO ===\n")

nombre = IO.gets("Nombre del equipo: ") |> String.trim()
tema = IO.gets("Tema del proyecto: ") |> String.trim()

IO.puts("\nCategorias disponibles:")
IO.puts(" 1. Social")
IO.puts(" 2. Ambiental")
IO.puts(" 3. Educativo")
IO.puts(" 4. Salud")
IO.puts(" 5. Tecnologia")
IO.puts(" 6. Otro")

categoria_opcion = IO.gets("\nSeleccione categoria: ") |> String.trim()

categoria = case categoria_opcion do
"1" -> :social
"2" -> :ambiental
"3" -> :educativo
"4" -> :salud
"5" -> :tecnologia
"6" -> :otro
_ -> nil
end

if categoria do
case GestionEquipos.crear_equipo(%{nombre: nombre, tema: tema, categoria: categoria}) do
{:ok, equipo} ->
IO.puts("\n+ Equipo '#{equipo.nombre}' creado exitosamente!")
IO.puts(" ID: #{equipo.id}")
IO.puts(" Tema: #{equipo.tema}")
IO.puts(" Categoria: #{equipo.categoria}\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end
else
IO.puts("\nX Categoria invalida\n")
end

pausar()
end

defp crear_proyecto do
IO.puts("\n=== CREAR NUEVO PROYECTO ===\n")

case GestionEquipos.listar_equipos() do
{:ok, [_|_] = equipos} ->
IO.puts("Equipos disponibles:\n")

equipos
|> Enum.with_index(1)
|> Enum.each(fn {equipo, index} ->
IO.puts(" #{index}. #{equipo.nombre}")
end)

IO.puts("\nSeleccione el numero del equipo:")
equipo_opcion = IO.gets("> ") |> String.trim()

case Integer.parse(equipo_opcion) do
{index, _} when index > 0 and index <= length(equipos) ->
equipo = Enum.at(equipos, index - 1)

nombre = IO.gets("\nNombre del proyecto: ") |> String.trim()

IO.puts("Descripcion (minimo 20 caracteres):")
descripcion = IO.gets("> ") |> String.trim()

IO.puts("\nCategorias: 1.Social 2.Ambiental 3.Educativo 4.Salud 5.Tecnologia 6.Otro")
cat_opcion = IO.gets("Categoria: ") |> String.trim()

categoria = case cat_opcion do
"1" -> :social
"2" -> :ambiental
"3" -> :educativo
"4" -> :salud
"5" -> :tecnologia
"6" -> :otro
_ -> nil
end

if categoria do
case GestionProyectos.registrar_proyecto(%{
nombre: nombre,
descripcion: descripcion,
categoria: categoria,
equipo_id: equipo.id
}) do
{:ok, proyecto} ->
IO.puts("\n+ Proyecto '#{proyecto.nombre}' creado exitosamente!")
IO.puts(" Equipo: #{equipo.nombre}")
IO.puts(" Estado: #{proyecto.estado}\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end
else
IO.puts("\nX Categoria invalida\n")
end

_ ->
IO.puts("\nOpcion invalida.\n")
end

{:ok, []} ->
IO.puts("No hay equipos disponibles. Cree un equipo primero.\n")

_ ->
IO.puts("Error al obtener equipos.\n")
end

pausar()
end

defp asignar_mentor_equipo do
IO.puts("\n=== ASIGNAR MENTOR A EQUIPO ===\n")

case GestionMentores.listar_mentores() do
{:ok, [_|_] = mentores} ->
IO.puts("Mentores disponibles:\n")

mentores
|> Enum.with_index(1)
|> Enum.each(fn {mentor, index} ->
capacidad = mentor.max_equipos - length(mentor.equipos_asignados)
estado = if capacidad > 0, do: "#{capacidad} espacios disponibles", else: "LLENO"
IO.puts(" #{index}. #{mentor.nombre} - #{mentor.especialidad} (#{estado})")
end)

IO.puts("\nSeleccione el numero del mentor:")
mentor_opcion = IO.gets("> ") |> String.trim()

case Integer.parse(mentor_opcion) do
{index, _} when index > 0 and index <= length(mentores) ->
mentor = Enum.at(mentores, index - 1)

if length(mentor.equipos_asignados) >= mentor.max_equipos do
IO.puts("\nX Este mentor ya tiene el maximo de equipos asignados (#{mentor.max_equipos}).\n")
else
case GestionEquipos.listar_equipos() do
{:ok, [_|_] = equipos} ->
IO.puts("\nEquipos disponibles:\n")

equipos
|> Enum.with_index(1)
|> Enum.each(fn {equipo, idx} ->
ya_asignado = equipo.id in mentor.equipos_asignados
estado = if ya_asignado, do: "(YA ASIGNADO)", else: ""
IO.puts(" #{idx}. #{equipo.nombre} - #{equipo.tema} #{estado}")
end)

IO.puts("\nSeleccione el numero del equipo:")
equipo_opcion = IO.gets("> ") |> String.trim()

case Integer.parse(equipo_opcion) do
{eq_idx, _} when eq_idx > 0 and eq_idx <= length(equipos) ->
equipo = Enum.at(equipos, eq_idx - 1)

case GestionMentores.asignar_a_equipo(mentor.id, equipo.id) do
{:ok, _} ->
IO.puts("\n+ Mentor '#{mentor.nombre}' asignado exitosamente al equipo '#{equipo.nombre}'!\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end

_ ->
IO.puts("\nOpcion invalida.\n")
end

{:ok, []} ->
IO.puts("\nNo hay equipos disponibles.\n")

_ ->
IO.puts("\nError al obtener equipos.\n")
end
end

_ ->
IO.puts("\nOpcion invalida.\n")
end

{:ok, []} ->
IO.puts("No hay mentores registrados.\n")

_ ->
IO.puts("Error al obtener mentores.\n")
end

pausar()
end

defp cambiar_estado_proyecto do
IO.puts("\n=== CAMBIAR ESTADO DE PROYECTO ===\n")

case GestionProyectos.listar_proyectos() do
{:ok, [_|_] = proyectos} ->
IO.puts("Proyectos disponibles:\n")

proyectos
|> Enum.with_index(1)
|> Enum.each(fn {proyecto, index} ->
IO.puts(" #{index}. #{proyecto.nombre} [Estado actual: #{estado_texto(proyecto.estado)}]")
end)

IO.puts("\nSeleccione el numero del proyecto:")
proyecto_opcion = IO.gets("> ") |> String.trim()

case Integer.parse(proyecto_opcion) do
{index, _} when index > 0 and index <= length(proyectos) ->
proyecto = Enum.at(proyectos, index - 1)

IO.puts("\n=== Proyecto: #{proyecto.nombre} ===")
IO.puts("Estado actual: #{estado_texto(proyecto.estado)}\n")
IO.puts("Seleccione el nuevo estado:")
IO.puts(" 1. Iniciado")
IO.puts(" 2. En Progreso")
IO.puts(" 3. Finalizado")
IO.puts(" 4. Presentado")

estado_opcion = IO.gets("\n> ") |> String.trim()

nuevo_estado = case estado_opcion do
"1" -> :iniciado
"2" -> :en_progreso
"3" -> :finalizado
"4" -> :presentado
_ -> nil
end

if nuevo_estado do
case GestionProyectos.cambiar_estado(proyecto.id, nuevo_estado) do
{:ok, _} ->
IO.puts("\n+ Estado del proyecto '#{proyecto.nombre}' cambiado a '#{estado_texto(nuevo_estado)}' exitosamente!\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end
else
IO.puts("\nX Estado invalido.\n")
end

_ ->
IO.puts("\nOpcion invalida.\n")
end

{:ok, []} ->
IO.puts("No hay proyectos disponibles.\n")

_ ->
IO.puts("Error al obtener proyectos.\n")
end

pausar()
end

# ============================================
# FUNCIONES DE COLABORACIÓN
# ============================================

defp agregar_avance do
IO.puts("\n=== AGREGAR AVANCE A PROYECTO ===\n")

case GestionProyectos.listar_proyectos() do
{:ok, [_|_] = proyectos} ->
proyectos
|> Enum.with_index(1)
|> Enum.each(fn {proyecto, index} ->
IO.puts(" #{index}. #{proyecto.nombre} [#{proyecto.estado}]")
end)

IO.puts("\nSeleccione el numero del proyecto:")
proyecto_opcion = IO.gets("> ") |> String.trim()

case Integer.parse(proyecto_opcion) do
{index, _} when index > 0 and index <= length(proyectos) ->
proyecto = Enum.at(proyectos, index - 1)

IO.puts("\nDescripcion del avance:")
avance = IO.gets("> ") |> String.trim()

case GestionProyectos.agregar_avance(proyecto.id, avance) do
{:ok, _} ->
IO.puts("\n+ Avance agregado exitosamente al proyecto '#{proyecto.nombre}'!\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end

_ ->
IO.puts("\nOpcion invalida.\n")
end

{:ok, []} ->
IO.puts("No hay proyectos disponibles.\n")

_ ->
IO.puts("Error al obtener proyectos.\n")
end

pausar()
end

defp ver_chat_equipo do
IO.puts("\n=== CHAT DE EQUIPO ===\n")

case GestionEquipos.listar_equipos() do
{:ok, [_|_] = equipos} ->
equipos
|> Enum.with_index(1)
|> Enum.each(fn {equipo, index} ->
IO.puts(" #{index}. #{equipo.nombre}")
end)

IO.puts("\nSeleccione el numero del equipo:")
equipo_opcion = IO.gets("> ") |> String.trim()

case Integer.parse(equipo_opcion) do
{index, _} when index > 0 and index <= length(equipos) ->
equipo = Enum.at(equipos, index - 1)
canal = "equipo_#{equipo.id}"

case SistemaChat.obtener_historial(canal) do
{:ok, mensajes} ->
IO.puts("\n--- Mensajes de '#{equipo.nombre}' ---\n")

if Enum.empty?(mensajes) do
IO.puts(" No hay mensajes aun.\n")
else
Enum.each(mensajes, fn mensaje ->
fecha = Calendar.strftime(mensaje.fecha, "%d/%m %H:%M")
IO.puts(" [#{fecha}] #{String.slice(mensaje.emisor_id, 0..7)}: #{mensaje.contenido}")
end)
IO.puts("")
end

_ ->
IO.puts("Error al obtener mensajes\n")
end

_ ->
IO.puts("\nOpcion invalida.\n")
end

{:ok, []} ->
IO.puts("No hay equipos disponibles.\n")

_ ->
IO.puts("Error al obtener equipos.\n")
end

pausar()
end

defp enviar_mensaje_chat do
IO.puts("\n=== ENVIAR MENSAJE A EQUIPO ===\n")

IO.puts("Ingrese su correo electronico:")
correo = IO.gets("> ") |> String.trim()

case GestionParticipantes.buscar_por_correo(correo) do
{:ok, participante} ->
if participante.equipo_id do
case GestionEquipos.obtener_equipo(participante.equipo_id) do
{:ok, equipo} ->
IO.puts("\nEquipo: #{equipo.nombre}")
IO.puts("Escriba su mensaje:")
mensaje = IO.gets("> ") |> String.trim()

if String.length(mensaje) > 0 do
canal = "equipo_#{equipo.id}"

case SistemaChat.enviar_mensaje(participante.id, mensaje, canal) do
{:ok, _} ->
IO.puts("\n+ Mensaje enviado exitosamente!\n")
_ ->
IO.puts("\nX Error al enviar mensaje\n")
end
else
IO.puts("\nMensaje vacio. No se envio nada.\n")
end

_ ->
IO.puts("\nError al obtener equipo.\n")
end
else
IO.puts("\nNo estas asignado a ningun equipo. Unete a uno primero.\n")
end

{:error, :no_encontrado} ->
IO.puts("\nParticipante no encontrado. Registrese primero.\n")

_ ->
IO.puts("\nError al buscar participante.\n")
end

pausar()
end

# ============================================
# FUNCIONES DE ELIMINACIÓN
# ============================================

defp eliminar_participante do
case verificar_acceso_admin() do
{:ok, :autorizado} ->
IO.puts("\n=== ELIMINAR PARTICIPANTE ===\n")

case GestionParticipantes.listar_participantes() do
{:ok, [_|_] = participantes} ->
participantes
|> Enum.with_index(1)
|> Enum.each(fn {p, index} ->
IO.puts(" #{index}. #{p.nombre} (#{p.correo})")
end)

IO.puts("\nSeleccione el numero del participante a eliminar:")
opcion = IO.gets("> ") |> String.trim()

case Integer.parse(opcion) do
{index, _} when index > 0 and index <= length(participantes) ->
participante = Enum.at(participantes, index - 1)

IO.puts("\nEsta seguro de eliminar a '#{participante.nombre}'? (si/no)")
confirmacion = IO.gets("> ") |> String.trim() |> String.downcase()

if confirmacion == "si" do
case GestionParticipantes.eliminar_participante(participante.id) do
{:ok, :eliminado} ->
IO.puts("\n+ Participante eliminado exitosamente\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end
else
IO.puts("\nOperacion cancelada\n")
end

_ ->
IO.puts("\nOpcion invalida\n")
end

{:ok, []} ->
IO.puts("No hay participantes registrados\n")

_ ->
IO.puts("Error al listar participantes\n")
end

{:error, :no_autorizado} ->
:ok
end

pausar()
end

defp eliminar_mentor do
case verificar_acceso_admin() do
{:ok, :autorizado} ->
IO.puts("\n=== ELIMINAR MENTOR ===\n")

case GestionMentores.listar_mentores() do
{:ok, [_|_] = mentores} ->
mentores
|> Enum.with_index(1)
|> Enum.each(fn {m, index} ->
IO.puts(" #{index}. #{m.nombre} (#{m.correo})")
end)

IO.puts("\nSeleccione el numero del mentor a eliminar:")
opcion = IO.gets("> ") |> String.trim()

case Integer.parse(opcion) do
{index, _} when index > 0 and index <= length(mentores) ->
mentor = Enum.at(mentores, index - 1)

IO.puts("\nEsta seguro de eliminar a '#{mentor.nombre}'? (si/no)")
confirmacion = IO.gets("> ") |> String.trim() |> String.downcase()

if confirmacion == "si" do
case GestionMentores.eliminar_mentor(mentor.id) do
{:ok, :eliminado} ->
IO.puts("\n+ Mentor eliminado exitosamente\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end
else
IO.puts("\nOperacion cancelada\n")
end

_ ->
IO.puts("\nOpcion invalida\n")
end

{:ok, []} ->
IO.puts("No hay mentores registrados\n")

_ ->
IO.puts("Error al listar mentores\n")
end

{:error, :no_autorizado} ->
:ok
end

pausar()
end

defp eliminar_equipo do
IO.puts("\n=== ELIMINAR EQUIPO ===\n")

case GestionEquipos.listar_equipos() do
{:ok, [_|_] = equipos} ->
equipos
|> Enum.with_index(1)
|> Enum.each(fn {e, index} ->
IO.puts(" #{index}. #{e.nombre}")
end)

IO.puts("\nSeleccione el numero del equipo a eliminar:")
opcion = IO.gets("> ") |> String.trim()

case Integer.parse(opcion) do
{index, _} when index > 0 and index <= length(equipos) ->
equipo = Enum.at(equipos, index - 1)

IO.puts("\nEsta seguro de eliminar el equipo '#{equipo.nombre}'? (si/no)")
confirmacion = IO.gets("> ") |> String.trim() |> String.downcase()

if confirmacion == "si" do
case GestionEquipos.eliminar_equipo(equipo.id) do
{:ok, :eliminado} ->
IO.puts("\n+ Equipo eliminado exitosamente\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end
else
IO.puts("\nOperacion cancelada\n")
end

_ ->
IO.puts("\nOpcion invalida\n")
end

{:ok, []} ->
IO.puts("No hay equipos registrados\n")

_ ->
IO.puts("Error al listar equipos\n")
end

pausar()
end

defp eliminar_proyecto do
IO.puts("\n=== ELIMINAR PROYECTO ===\n")

case GestionProyectos.listar_proyectos() do
{:ok, [_|_] = proyectos} ->
proyectos
|> Enum.with_index(1)
|> Enum.each(fn {p, index} ->
IO.puts(" #{index}. #{p.nombre} [#{p.estado}]")
end)

IO.puts("\nSeleccione el numero del proyecto a eliminar:")
opcion = IO.gets("> ") |> String.trim()

case Integer.parse(opcion) do
{index, _} when index > 0 and index <= length(proyectos) ->
proyecto = Enum.at(proyectos, index - 1)

IO.puts("\nEsta seguro de eliminar el proyecto '#{proyecto.nombre}'? (si/no)")
confirmacion = IO.gets("> ") |> String.trim() |> String.downcase()

if confirmacion == "si" do
case GestionProyectos.eliminar_proyecto(proyecto.id) do
{:ok, :eliminado} ->
IO.puts("\n+ Proyecto eliminado exitosamente\n")
{:error, razon} ->
IO.puts("\nX Error: #{razon}\n")
end
else
IO.puts("\nOperacion cancelada\n")
end

_ ->
IO.puts("\nOpcion invalida\n")
end

{:ok, []} ->
IO.puts("No hay proyectos registrados\n")

_ ->
IO.puts("Error al listar proyectos\n")
end

pausar()
end

# ============================================
# FUNCIONES DE SISTEMA
# ============================================

defp mostrar_ayuda do
IO.puts("\n")
IO.puts("===============================================")
IO.puts(" AYUDA - COMANDOS ")
IO.puts("===============================================")
IO.puts("")
IO.puts(" FLUJO RECOMENDADO:")
IO.puts(" 1. REGISTROS > Registrar participante")
IO.puts(" 2. CONSULTAS > Ver equipos disponibles")
IO.puts(" 3. REGISTROS > Unirse a un equipo")
IO.puts(" 4. COLABORACION > Enviar mensajes")
IO.puts(" 5. COLABORACION > Agregar avances")
IO.puts("")
IO.puts(" NAVEGACION:")
IO.puts(" - Use numeros (1-6) para navegar")
IO.puts(" - Presione 0 para volver al menu anterior")
IO.puts("")
IO.puts(" ACCESO ADMINISTRATIVO:")
IO.puts(" - Ver/eliminar participantes y mentores")
IO.puts(" - Contraseña: #{@password_acceso}")
IO.puts("")
IO.puts("===============================================")
IO.puts("")

pausar()
end

defp recargar_datos do
IO.puts("\n")
IO.puts("===============================================")
IO.puts(" RESUMEN DE DATOS ACTUALES ")
IO.puts("===============================================")
IO.puts("")

case GestionParticipantes.listar_participantes() do
{:ok, participantes} ->
IO.puts(" PARTICIPANTES: #{length(participantes)}")
if length(participantes) > 0 do
Enum.take(participantes, 5)
|> Enum.each(fn p ->
equipo = case p.equipo_id do
nil -> "Sin equipo"
equipo_id ->
case GestionEquipos.obtener_equipo(equipo_id) do
{:ok, eq} -> eq.nombre
_ -> "Equipo desconocido"
end
end
IO.puts("  #{p.nombre} (#{p.correo}) - #{equipo}")
end)
if length(participantes) > 5 do
IO.puts(" ... y #{length(participantes) - 5} más")
end
end
IO.puts("")
_ ->
IO.puts(" PARTICIPANTES: 0\n")
end

case GestionMentores.listar_mentores() do
{:ok, mentores} ->
IO.puts(" MENTORES: #{length(mentores)}")
if length(mentores) > 0 do
Enum.each(mentores, fn m ->
IO.puts(" • #{m.nombre} - #{m.especialidad}")
end)
end
IO.puts("")
_ ->
IO.puts(" MENTORES: 0\n")
end

case GestionEquipos.listar_equipos() do
{:ok, equipos} ->
IO.puts(" EQUIPOS: #{length(equipos)}")
if length(equipos) > 0 do
Enum.each(equipos, fn e ->
IO.puts(" • #{e.nombre} (#{e.tema}) - #{length(e.miembros)} miembros")
end)
end
IO.puts("")
_ ->
IO.puts(" EQUIPOS: 0\n")
end

case GestionProyectos.listar_proyectos() do
{:ok, proyectos} ->
IO.puts(" PROYECTOS: #{length(proyectos)}")
if length(proyectos) > 0 do
Enum.each(proyectos, fn p ->
IO.puts(" • #{p.nombre} [#{p.estado}] - #{length(p.avances)} avances")
end)
end
IO.puts("")
_ ->
IO.puts(" PROYECTOS: 0\n")
end

case SistemaChat.obtener_estadisticas() do
{:ok, stats} ->
IO.puts(" MENSAJES: #{stats.mensajes_enviados}")
IO.puts(" CANALES ACTIVOS: #{stats.canales_activos}")
IO.puts("")
_ ->
IO.puts(" MENSAJES: 0\n")
end

IO.puts("===============================================")
IO.puts(" Datos actualizados correctamente")
IO.puts("===============================================")
IO.puts("")

pausar()
end

defp salir do
IO.puts("\n")
IO.puts("===============================================")
IO.puts(" ")
IO.puts(" Gracias por usar Code4Future! ")
IO.puts(" ")
IO.puts(" Desarrollado en Elixir ")
IO.puts(" ")
IO.puts("===============================================")
IO.puts("\n")
System.halt(0)
end

# ============================================
# FUNCIONES AUXILIARES
# ============================================

defp mostrar_proyecto_detallado(proyecto, index) do
IO.puts(" #{index}. [#{estado_texto(proyecto.estado)}] #{proyecto.nombre}")
IO.puts(" Descripcion: #{proyecto.descripcion}")
IO.puts(" Categoria: #{proyecto.categoria}")
IO.puts(" Estado: #{proyecto.estado}")
IO.puts(" Avances registrados: #{length(proyecto.avances)}")

if length(proyecto.avances) > 0 do
IO.puts(" Ultimos avances:")
Enum.take(proyecto.avances, 3)
|> Enum.each(fn avance ->
IO.puts(" - #{avance.contenido}")
end)
end

IO.puts(" Retroalimentaciones: #{length(proyecto.retroalimentacion)}")

if length(proyecto.retroalimentacion) > 0 do
IO.puts(" Comentarios de mentores:")
Enum.take(proyecto.retroalimentacion, 2)
|> Enum.each(fn retro ->
IO.puts(" - #{retro.comentario}")
end)
end

IO.puts("")
end

defp estado_texto(estado) do
case estado do
:iniciado -> "INICIADO"
:en_progreso -> "EN PROGRESO"
:finalizado -> "FINALIZADO"
:presentado -> "PRESENTADO"
_ -> "DESCONOCIDO"
end
end

defp pausar do
IO.gets("\nPresione ENTER para continuar...")
:ok
end
# ============================================
# CANAL GENERAL Y RETROALIMENTACIÓN
# ============================================

defp ver_canal_general do
  IO.puts("\n")
  IO.puts("===============================================")
  IO.puts("          CANAL GENERAL DE ANUNCIOS           ")
  IO.puts("===============================================")
  IO.puts("")

  canal = "general"

  case SistemaChat.obtener_historial(canal) do
    {:ok, mensajes} ->
      if Enum.empty?(mensajes) do
        IO.puts("   No hay anuncios aun.\n")
      else
        IO.puts("   Anuncios del sistema:\n")
        Enum.each(mensajes, fn mensaje ->
          fecha = Calendar.strftime(mensaje.fecha, "%d/%m/%Y %H:%M")
          emisor = obtener_nombre_emisor(mensaje.emisor_id)
          IO.puts("  [#{fecha}] #{emisor}:")
          IO.puts("  #{mensaje.contenido}")
          IO.puts("")
        end)
      end

    _ ->
      IO.puts("   Error al obtener anuncios\n")
  end

  pausar()
end

defp enviar_anuncio_general do
  IO.puts("\n=== ENVIAR ANUNCIO GENERAL ===\n")
  IO.puts("Este mensaje sera visible para TODOS los participantes")
  IO.puts("")
  IO.puts("Ingrese su correo de mentor:")
  correo = IO.gets("> ") |> String.trim()

  case buscar_mentor_por_correo(correo) do
    {:ok, mentor} ->
      IO.puts("\nMentor: #{mentor.nombre}")
      IO.puts("Escriba el anuncio:")
      mensaje = IO.gets("> ") |> String.trim()

      if String.length(mensaje) > 0 do
        canal = "general"

        case SistemaChat.enviar_mensaje(mentor.id, mensaje, canal) do
          {:ok, _} ->
            IO.puts("\n+ Anuncio enviado exitosamente al canal general!\n")
          _ ->
            IO.puts("\n Error al enviar anuncio\n")
        end
      else
        IO.puts("\nMensaje vacio. No se envio nada.\n")
      end

    {:error, :no_encontrado} ->
      IO.puts("\nMentor no encontrado. Solo mentores pueden enviar anuncios.\n")

    _ ->
      IO.puts("\nError al buscar mentor.\n")
  end

  pausar()
end

defp dar_retroalimentacion_mentor do
  IO.puts("\n=== DAR RETROALIMENTACION A PROYECTO ===\n")

  IO.puts("Ingrese su correo de mentor:")
  correo = IO.gets("> ") |> String.trim()

  case buscar_mentor_por_correo(correo) do
    {:ok, mentor} ->
      IO.puts("\nMentor: #{mentor.nombre}")
      IO.puts("Especialidad: #{mentor.especialidad}\n")

      case GestionProyectos.listar_proyectos() do
        {:ok, [_|_] = proyectos} ->
          IO.puts("Proyectos disponibles:\n")

          proyectos
          |> Enum.with_index(1)
          |> Enum.each(fn {proyecto, index} ->
            equipo_nombre = case GestionEquipos.obtener_equipo(proyecto.equipo_id) do
              {:ok, equipo} -> equipo.nombre
              _ -> "Equipo desconocido"
            end

            IO.puts("  #{index}. #{proyecto.nombre}")
            IO.puts("     Equipo: #{equipo_nombre}")
            IO.puts("     Estado: #{estado_texto(proyecto.estado)}")
            IO.puts("     Avances: #{length(proyecto.avances)}")
            IO.puts("")
          end)

          IO.puts("Seleccione el numero del proyecto:")
          proyecto_opcion = IO.gets("> ") |> String.trim()

          case Integer.parse(proyecto_opcion) do
            {index, _} when index > 0 and index <= length(proyectos) ->
              proyecto = Enum.at(proyectos, index - 1)

              IO.puts("\n=== Proyecto: #{proyecto.nombre} ===")
              IO.puts("Descripcion: #{proyecto.descripcion}")
              IO.puts("\nUltimos avances:")

              Enum.take(proyecto.avances, 3)
              |> Enum.each(fn avance ->
                fecha = Calendar.strftime(avance.fecha, "%d/%m/%Y")
                IO.puts("  • [#{fecha}] #{avance.contenido}")
              end)

              IO.puts("\n\nEscriba su retroalimentacion:")
              comentario = IO.gets("> ") |> String.trim()

              if String.length(comentario) > 0 do
                case GestionProyectos.agregar_retroalimentacion(
                  proyecto.id,
                  mentor.id,
                  comentario
                ) do
                  {:ok, _} ->
                    IO.puts("\n+ Retroalimentacion agregada exitosamente!")
                    IO.puts("  El equipo podra verla en su proyecto.\n")
                  {:error, razon} ->
                    IO.puts("\n Error: #{razon}\n")
                end
              else
                IO.puts("\nComentario vacio. Operacion cancelada.\n")
              end

            _ ->
              IO.puts("\nOpcion invalida.\n")
          end

        {:ok, []} ->
          IO.puts("No hay proyectos registrados aun.\n")

        _ ->
          IO.puts("Error al obtener proyectos.\n")
      end

    {:error, :no_encontrado} ->
      IO.puts("\nMentor no encontrado.")
      IO.puts("Verifique el correo o registrese primero (REGISTROS > Opcion 5).\n")

    _ ->
      IO.puts("\nError al buscar mentor.\n")
  end

  pausar()
end

# Helper para obtener nombre del emisor
defp obtener_nombre_emisor("sistema"), do: "SISTEMA"

defp obtener_nombre_emisor(id) do
  case GestionParticipantes.obtener_participante(id) do
    {:ok, p} -> " #{p.nombre}"
    _ ->
      case buscar_mentor_por_id(id) do
        {:ok, m} -> " #{m.nombre} (Mentor)"
        _ -> "Usuario #{String.slice(id, 0..7)}"
      end
  end
end

defp buscar_mentor_por_correo(correo) do
  case GestionMentores.listar_mentores() do
    {:ok, mentores} ->
      case Enum.find(mentores, fn m -> String.downcase(m.correo) == String.downcase(correo) end) do
        nil -> {:error, :no_encontrado}
        mentor -> {:ok, mentor}
      end
    error -> error
  end
end

defp buscar_mentor_por_id(id) do
  case GestionMentores.listar_mentores() do
    {:ok, mentores} ->
      case Enum.find(mentores, fn m -> m.id == id end) do
        nil -> {:error, :no_encontrado}
        mentor -> {:ok, mentor}
      end
    error -> error
  end
end

# ============================================
# GESTIÓN DE SALAS TEMÁTICAS
# ============================================

defp gestionar_salas_tematicas do
  IO.puts("\n")
  IO.puts("============ SALAS TEMATICAS ===============")
  IO.puts("")
  IO.puts(" 1. Ver salas públicas")
  IO.puts(" 2. Crear nueva sala")
  IO.puts(" 3. Unirse a una sala")
  IO.puts(" 4. Ver mensajes de sala")
  IO.puts(" 5. Enviar mensaje a sala")
  IO.puts(" 6. Salir de una sala")
  IO.puts("")
  IO.puts(" 0. ← Volver")
  IO.puts("")
  IO.puts("===============================================")

  case obtener_opcion() do
    "1" -> ver_salas_publicas() |> then(fn _ -> gestionar_salas_tematicas() end)
    "2" -> crear_sala_tematica() |> then(fn _ -> gestionar_salas_tematicas() end)
    "3" -> unirse_sala_tematica() |> then(fn _ -> gestionar_salas_tematicas() end)
    "4" -> ver_mensajes_sala() |> then(fn _ -> gestionar_salas_tematicas() end)
    "5" -> enviar_mensaje_sala() |> then(fn _ -> gestionar_salas_tematicas() end)
    "6" -> salir_sala_tematica() |> then(fn _ -> gestionar_salas_tematicas() end)
    "0" -> :volver
    _ ->
      IO.puts("\nX Opcion invalida.\n")
      gestionar_salas_tematicas()
  end
end

defp ver_salas_publicas do
  IO.puts("\n=== SALAS PÚBLICAS DISPONIBLES ===\n")

  case Hackathon.Services.GestionSalas.listar_salas_publicas() do
    {:ok, []} ->
      IO.puts("  No hay salas públicas disponibles.\n")

    {:ok, salas} ->
      salas
      |> Enum.with_index(1)
      |> Enum.each(fn {sala, index} ->
        IO.puts("  #{index}. #{sala.nombre}")
        IO.puts("     Descripción: #{sala.descripcion}")
        IO.puts("     Tipo: #{sala.tipo}")
        IO.puts("     Miembros: #{length(sala.miembros)}")
        IO.puts("")
      end)

    _ ->
      IO.puts("  Error al obtener salas\n")
  end

  pausar()
end

defp crear_sala_tematica do
  IO.puts("\n=== CREAR SALA TEMÁTICA ===\n")

  IO.puts("Ingrese su correo:")
  correo = IO.gets("> ") |> String.trim()

  case GestionParticipantes.buscar_por_correo(correo) do
    {:ok, participante} ->
      nombre = IO.gets("\nNombre de la sala: ") |> String.trim()
      descripcion = IO.gets("Descripción: ") |> String.trim()

      IO.puts("\nTipo de sala:")
      IO.puts(" 1. General")
      IO.puts(" 2. Técnica")
      IO.puts(" 3. Networking")
      IO.puts(" 4. Ayuda")

      tipo = case IO.gets("> ") |> String.trim() do
        "1" -> :general
        "2" -> :tecnica
        "3" -> :networking
        "4" -> :ayuda
        _ -> :general
      end

      case Hackathon.Services.GestionSalas.crear_sala(%{
        nombre: nombre,
        descripcion: descripcion,
        creador_id: participante.id,
        tipo: tipo
      }) do
        {:ok, sala} ->
          IO.puts("\n✓ Sala '#{sala.nombre}' creada exitosamente!")
          IO.puts("  ID: #{sala.id}\n")

        {:error, razon} ->
          IO.puts("\nX Error: #{razon}\n")
      end

    {:error, :no_encontrado} ->
      IO.puts("\nUsuario no encontrado.\n")

    _ ->
      IO.puts("\nError al buscar usuario.\n")
  end

  pausar()
end

defp unirse_sala_tematica do
  IO.puts("\n=== UNIRSE A SALA TEMÁTICA ===\n")

  case Hackathon.Services.GestionSalas.listar_salas_publicas() do
    {:ok, [_|_] = salas} ->
      salas
      |> Enum.with_index(1)
      |> Enum.each(fn {sala, index} ->
        IO.puts("  #{index}. #{sala.nombre} (#{length(sala.miembros)} miembros)")
      end)

      IO.puts("\nSeleccione el número de la sala:")
      sala_opcion = IO.gets("> ") |> String.trim()

      case Integer.parse(sala_opcion) do
        {index, _} when index > 0 and index <= length(salas) ->
          sala = Enum.at(salas, index - 1)

          IO.puts("\nIngrese su correo:")
          correo = IO.gets("> ") |> String.trim()

          case GestionParticipantes.buscar_por_correo(correo) do
            {:ok, participante} ->
              case Hackathon.Services.GestionSalas.unirse_a_sala(sala.id, participante.id) do
                {:ok, _} ->
                  IO.puts("\n✓ Te has unido a la sala '#{sala.nombre}'!\n")

                {:error, razon} ->
                  IO.puts("\nX Error: #{razon}\n")
              end

            _ ->
              IO.puts("\nUsuario no encontrado.\n")
          end

        _ ->
          IO.puts("\nOpción inválida.\n")
      end

    {:ok, []} ->
      IO.puts("  No hay salas disponibles.\n")

    _ ->
      IO.puts("  Error al obtener salas.\n")
  end

  pausar()
end

defp ver_mensajes_sala do
  IO.puts("\n=== VER MENSAJES DE SALA ===\n")

  IO.puts("Ingrese su correo:")
  correo = IO.gets("> ") |> String.trim()

  case GestionParticipantes.buscar_por_correo(correo) do
    {:ok, participante} ->
      case Hackathon.Services.GestionSalas.listar_salas_publicas() do
        {:ok, [_|_] = salas} ->
          # Filtrar salas donde el usuario es miembro
          mis_salas = Enum.filter(salas, fn s ->
            participante.id in s.miembros or participante.id == s.creador_id
          end)

          if Enum.empty?(mis_salas) do
            IO.puts("\nNo perteneces a ninguna sala aún.\n")
          else
            mis_salas
            |> Enum.with_index(1)
            |> Enum.each(fn {sala, index} ->
              IO.puts("  #{index}. #{sala.nombre}")
            end)

            IO.puts("\nSeleccione la sala:")
            opcion = IO.gets("> ") |> String.trim()

            case Integer.parse(opcion) do
              {index, _} when index > 0 and index <= length(mis_salas) ->
                sala = Enum.at(mis_salas, index - 1)

                case SistemaChat.obtener_historial_sala(sala.id, participante.id) do
                  {:ok, mensajes} ->
                    IO.puts("\n--- Mensajes en '#{sala.nombre}' ---\n")

                    if Enum.empty?(mensajes) do
                      IO.puts("  No hay mensajes aún.\n")
                    else
                      Enum.each(mensajes, fn m ->
                        fecha = Calendar.strftime(m.fecha, "%d/%m %H:%M")
                        IO.puts("  [#{fecha}] #{String.slice(m.emisor_id, 0..7)}: #{m.contenido}")
                      end)
                    end

                  _ ->
                    IO.puts("\nError al obtener mensajes.\n")
                end

              _ ->
                IO.puts("\nOpción inválida.\n")
            end
          end

        _ ->
          IO.puts("\nError al obtener salas.\n")
      end

    _ ->
      IO.puts("\nUsuario no encontrado.\n")
  end

  pausar()
end

defp enviar_mensaje_sala do
  IO.puts("\n=== ENVIAR MENSAJE A SALA ===\n")

  IO.puts("Ingrese su correo:")
  correo = IO.gets("> ") |> String.trim()

  case GestionParticipantes.buscar_por_correo(correo) do
    {:ok, participante} ->
      case Hackathon.Services.GestionSalas.listar_salas_publicas() do
        {:ok, salas} ->
          mis_salas = Enum.filter(salas, fn s ->
            participante.id in s.miembros or participante.id == s.creador_id
          end)

          if Enum.empty?(mis_salas) do
            IO.puts("\nNo perteneces a ninguna sala.\n")
          else
            mis_salas
            |> Enum.with_index(1)
            |> Enum.each(fn {sala, index} ->
              IO.puts("  #{index}. #{sala.nombre}")
            end)

            IO.puts("\nSeleccione la sala:")
            opcion = IO.gets("> ") |> String.trim()

            case Integer.parse(opcion) do
              {index, _} when index > 0 and index <= length(mis_salas) ->
                sala = Enum.at(mis_salas, index - 1)

                IO.puts("\nEscriba su mensaje:")
                mensaje = IO.gets("> ") |> String.trim()

                if String.length(mensaje) > 0 do
                  case SistemaChat.enviar_mensaje_sala(participante.id, mensaje, sala.id) do
                    {:ok, _} ->
                      IO.puts("\n✓ Mensaje enviado a '#{sala.nombre}'!\n")

                    {:error, razon} ->
                      IO.puts("\nX Error: #{razon}\n")
                  end
                else
                  IO.puts("\nMensaje vacío.\n")
                end

              _ ->
                IO.puts("\nOpción inválida.\n")
            end
          end

        _ ->
          IO.puts("\nError al obtener salas.\n")
      end

    _ ->
      IO.puts("\nUsuario no encontrado.\n")
  end

  pausar()
end

defp salir_sala_tematica do
  IO.puts("\n=== SALIR DE SALA ===\n")

  IO.puts("Ingrese su correo:")
  correo = IO.gets("> ") |> String.trim()

  case GestionParticipantes.buscar_por_correo(correo) do
    {:ok, participante} ->
      case Hackathon.Services.GestionSalas.listar_todas() do
        {:ok, salas} ->
          mis_salas = Enum.filter(salas, fn s -> participante.id in s.miembros end)

          if Enum.empty?(mis_salas) do
            IO.puts("\nNo perteneces a ninguna sala.\n")
          else
            mis_salas
            |> Enum.with_index(1)
            |> Enum.each(fn {sala, index} ->
              IO.puts("  #{index}. #{sala.nombre}")
            end)

            IO.puts("\nSeleccione la sala:")
            opcion = IO.gets("> ") |> String.trim()

            case Integer.parse(opcion) do
              {index, _} when index > 0 and index <= length(mis_salas) ->
                sala = Enum.at(mis_salas, index - 1)

                case Hackathon.Services.GestionSalas.salir_de_sala(sala.id, participante.id) do
                  {:ok, _} ->
                    IO.puts("\n✓ Has salido de la sala '#{sala.nombre}'.\n")

                  {:error, razon} ->
                    IO.puts("\nX Error: #{razon}\n")
                end

              _ ->
                IO.puts("\nOpción inválida.\n")
            end
          end

        _ ->
          IO.puts("\nError al obtener salas.\n")
      end

    _ ->
      IO.puts("\nUsuario no encontrado.\n")
  end

  pausar()
end

# ============================================
# MÉTRICAS DEL SISTEMA
# ============================================

defp ver_metricas_sistema do
  Hackathon.Metricas.Visualizador.mostrar_dashboard()
  pausar()
end




def iniciar_nodo(nombre_nodo) when is_binary(nombre_nodo) do
  nodo_atom = String.to_atom(nombre_nodo)
  iniciar_nodo(nodo_atom)
end

def iniciar_nodo(nombre_nodo) when is_atom(nombre_nodo) do
  # Iniciar en modo distribuido
  case Node.start(nombre_nodo, :shortnames) do
    {:ok, _} ->
      IO.puts("\n Nodo iniciado: #{Node.self()}")
      IO.puts(" Cookie: #{Node.get_cookie()}")

      # Banner
      Hackathon.Distribucion.Notificador.banner_bienvenida_cluster()

      # Activar notificaciones
      Hackathon.Distribucion.Notificador.activar()

      # Mantener vivo
      IO.puts("\n Para conectar a otro nodo desde el CLI:")
      IO.puts("   Opción 5 > Opción 9 > Opción 2")
      IO.puts("\n  Presiona Ctrl+C dos veces para salir\n")

      Process.sleep(:infinity)

    {:error, {:already_started, _}} ->
      IO.puts("\n Nodo ya iniciado: #{Node.self()}")
      Process.sleep(:infinity)

    error ->
      IO.puts("\n Error al iniciar nodo: #{inspect(error)}")
      System.halt(1)
  end
end

end
