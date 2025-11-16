defmodule Hackathon.Distribucion.Notificador do
  @moduledoc """
  Sistema de notificaciones visuales para eventos del cluster
  Muestra alertas destacadas cuando ocurren eventos importantes
  """
  use GenServer
  require Logger

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Activa las notificaciones visuales
  """
  def activar do
    GenServer.cast(__MODULE__, :activar)
  end

  @doc """
  Desactiva las notificaciones visuales
  """
  def desactivar do
    GenServer.cast(__MODULE__, :desactivar)
  end

  @doc """
  Envía una notificación personalizada
  """
  def notificar(tipo, mensaje, datos \\ %{}) do
    GenServer.cast(__MODULE__, {:notificar, tipo, mensaje, datos})
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    # Suscribirse a eventos de nodos
    :net_kernel.monitor_nodes(true, node_type: :all)

    estado = %{
      activo: true,
      notificaciones_enviadas: 0,
      ultima_notificacion: nil
    }

    {:ok, estado}
  end

  @impl true
  def handle_cast(:activar, estado) do
    IO.puts("\n Notificaciones visuales ACTIVADAS\n")
    {:noreply, %{estado | activo: true}}
  end

  @impl true
  def handle_cast(:desactivar, estado) do
    IO.puts("\n  Notificaciones visuales DESACTIVADAS\n")
    {:noreply, %{estado | activo: false}}
  end

  @impl true
  def handle_cast({:notificar, tipo, mensaje, datos}, estado) do
    if estado.activo do
      mostrar_notificacion(tipo, mensaje, datos)

      nuevo_estado = %{
        estado |
        notificaciones_enviadas: estado.notificaciones_enviadas + 1,
        ultima_notificacion: {tipo, mensaje, DateTime.utc_now()}
      }

      {:noreply, nuevo_estado}
    else
      {:noreply, estado}
    end
  end

  @impl true
  def handle_info({:nodeup, nodo, _info}, estado) do
    if estado.activo do
      mostrar_nodo_conectado(nodo)

      # Broadcast a otros nodos
      spawn(fn ->
        :timer.sleep(500)
        Hackathon.Distribucion.Nodo.broadcast({:notificacion_nodo, :conectado, nodo})
      end)
    end

    {:noreply, estado}
  end

  @impl true
  def handle_info({:nodedown, nodo, _info}, estado) do
    if estado.activo do
      mostrar_nodo_desconectado(nodo)

      # Broadcast a otros nodos
      spawn(fn ->
        :timer.sleep(500)
        Hackathon.Distribucion.Nodo.broadcast({:notificacion_nodo, :desconectado, nodo})
      end)
    end

    {:noreply, estado}
  end

  @impl true
  def handle_info(_msg, estado) do
    {:noreply, estado}
  end

  # Funciones privadas de visualización

  defp mostrar_notificacion(tipo, mensaje, datos) do
    case tipo do
      :exito -> mostrar_exito(mensaje, datos)
      :error -> mostrar_error(mensaje, datos)
      :advertencia -> mostrar_advertencia(mensaje, datos)
      :info -> mostrar_info(mensaje, datos)
      :cluster -> mostrar_cluster(mensaje, datos)
      _ -> mostrar_generica(mensaje, datos)
    end
  end

  defp mostrar_nodo_conectado(nodo) do
    IO.puts("\n")
    IO.puts("╔═══════════════════════════════════════════════════╗")
    IO.puts("║                                                   ║")
    IO.puts("║             NODO CONECTADO                      ║")
    IO.puts("║                                                   ║")
    IO.puts("╠═══════════════════════════════════════════════════╣")
    IO.puts("║                                                   ║")
    IO.puts("║  #{String.pad_trailing("Nodo: #{nodo}", 47)}  ║")
    IO.puts("║  #{String.pad_trailing("Hora: #{hora_actual()}", 47)}  ║")
    IO.puts("║  #{String.pad_trailing("Nodos activos: #{length(Node.list())}", 47)}  ║")
    IO.puts("║                                                   ║")
    IO.puts("╚═══════════════════════════════════════════════════╝")
    IO.puts("")

    # Emitir sonido (beep)
    IO.write("\a")
  end

  defp mostrar_nodo_desconectado(nodo) do
    IO.puts("\n")
    IO.puts("╔═══════════════════════════════════════════════════╗")
    IO.puts("║                                                   ║")
    IO.puts("║             NODO DESCONECTADO                   ║")
    IO.puts("║                                                   ║")
    IO.puts("╠═══════════════════════════════════════════════════╣")
    IO.puts("║                                                   ║")
    IO.puts("║  #{String.pad_trailing("Nodo: #{nodo}", 47)}  ║")
    IO.puts("║  #{String.pad_trailing("Hora: #{hora_actual()}", 47)}  ║")
    IO.puts("║  #{String.pad_trailing("Nodos restantes: #{length(Node.list())}", 47)}  ║")
    IO.puts("║                                                   ║")
    IO.puts("║    Auto-reconexión activada si está habilitada  ║")
    IO.puts("║                                                   ║")
    IO.puts("╚═══════════════════════════════════════════════════╝")
    IO.puts("")

    # Emitir sonidos de alerta
    IO.write("\a")
    :timer.sleep(200)
    IO.write("\a")
  end

  defp mostrar_exito(mensaje, datos) do
    IO.puts("\n")
    IO.puts("┌───────────────────────────────────────────────────┐")
    IO.puts("│   ÉXITO                                          │")
    IO.puts("├───────────────────────────────────────────────────┤")
    IO.puts("│ #{String.pad_trailing(mensaje, 49)} │")

    if map_size(datos) > 0 do
      Enum.each(datos, fn {k, v} ->
        linea = "  #{k}: #{v}"
        IO.puts("│ #{String.pad_trailing(linea, 49)} │")
      end)
    end

    IO.puts("└───────────────────────────────────────────────────┘")
    IO.puts("")
  end

  defp mostrar_error(mensaje, datos) do
    IO.puts("\n")
    IO.puts("╔═══════════════════════════════════════════════════╗")
    IO.puts("║   ERROR                                          ║")
    IO.puts("╠═══════════════════════════════════════════════════╣")
    IO.puts("║ #{String.pad_trailing(mensaje, 49)} ║")

    if map_size(datos) > 0 do
      Enum.each(datos, fn {k, v} ->
        linea = "  #{k}: #{v}"
        IO.puts("║ #{String.pad_trailing(linea, 49)} ║")
      end)
    end

    IO.puts("╚═══════════════════════════════════════════════════╝")
    IO.puts("")

    IO.write("\a")
  end

  defp mostrar_advertencia(mensaje, datos) do
    IO.puts("\n")
    IO.puts("┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
    IO.puts("┃    ADVERTENCIA                                   ┃")
    IO.puts("┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫")
    IO.puts("┃ #{String.pad_trailing(mensaje, 49)} ┃")

    if map_size(datos) > 0 do
      Enum.each(datos, fn {k, v} ->
        linea = "  #{k}: #{v}"
        IO.puts("┃ #{String.pad_trailing(linea, 49)} ┃")
      end)
    end

    IO.puts("┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛")
    IO.puts("")
  end

  defp mostrar_info(mensaje, datos) do
    IO.puts("\n")
    IO.puts("╭───────────────────────────────────────────────────╮")
    IO.puts("│    INFORMACIÓN                                   │")
    IO.puts("├───────────────────────────────────────────────────┤")
    IO.puts("│ #{String.pad_trailing(mensaje, 49)} │")

    if map_size(datos) > 0 do
      Enum.each(datos, fn {k, v} ->
        linea = "  #{k}: #{v}"
        IO.puts("│ #{String.pad_trailing(linea, 49)} │")
      end)
    end

    IO.puts("╰───────────────────────────────────────────────────╯")
    IO.puts("")
  end

  defp mostrar_cluster(mensaje, datos) do
    IO.puts("\n")
    IO.puts("╔═══════════════════════════════════════════════════╗")
    IO.puts("║   EVENTO DE CLUSTER                             ║")
    IO.puts("╠═══════════════════════════════════════════════════╣")
    IO.puts("║ #{String.pad_trailing(mensaje, 49)} ║")

    if map_size(datos) > 0 do
      Enum.each(datos, fn {k, v} ->
        linea = "  #{k}: #{v}"
        IO.puts("║ #{String.pad_trailing(linea, 49)} ║")
      end)
    end

    IO.puts("║                                                   ║")
    IO.puts("║ #{String.pad_trailing("Timestamp: #{hora_actual()}", 49)} ║")
    IO.puts("╚═══════════════════════════════════════════════════╝")
    IO.puts("")
  end

  defp mostrar_generica(mensaje, datos) do
    IO.puts("\n #{mensaje}")

    if map_size(datos) > 0 do
      Enum.each(datos, fn {k, v} ->
        IO.puts("   #{k}: #{v}")
      end)
    end

    IO.puts("")
  end

  defp hora_actual do
    DateTime.utc_now()
    |> Calendar.strftime("%H:%M:%S")
  end

  # Funciones auxiliares públicas

  @doc """
  Muestra una animación de sincronización
  """
  def animacion_sincronizacion do
    frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

    IO.write("\n Sincronizando ")

    Enum.each(1..20, fn i ->
      frame = Enum.at(frames, rem(i, length(frames)))
      IO.write("\r Sincronizando #{frame} ")
      :timer.sleep(100)
    end)

    IO.write("\r Sincronización completa!   \n\n")
  end

  @doc """
  Muestra progreso de conexión
  """
  def animacion_conexion(nodo) do
    IO.puts("\n Conectando a #{nodo}")
    IO.write("[")

    Enum.each(1..20, fn _ ->
      IO.write("█")
      :timer.sleep(50)
    end)

    IO.write("] ✓\n\n")
  end

  @doc """
  Banner de bienvenida al cluster
  """
  def banner_bienvenida_cluster do
    IO.puts("\n")
    IO.puts("╔═══════════════════════════════════════════════════════════╗")
    IO.puts("║                                                           ║")
    IO.puts("║           BIENVENIDO AL CLUSTER DISTRIBUIDO             ║")
    IO.puts("║                                                           ║")
    IO.puts("║              HACKATHON CODE4FUTURE 2025                   ║")
    IO.puts("║                                                           ║")
    IO.puts("╠═══════════════════════════════════════════════════════════╣")
    IO.puts("║                                                           ║")
    IO.puts("║  Tu nodo está ahora parte de un sistema distribuido      ║")
    IO.puts("║  que permite colaboración en tiempo real entre           ║")
    IO.puts("║  múltiples computadoras.                                 ║")
    IO.puts("║                                                           ║")
    IO.puts("║  Características activas:                                ║")
    IO.puts("║    - Sincronización automática de datos                 ║")
    IO.puts("║    - Chat distribuido                                    ║")
    IO.puts("║    - Broadcasting de mensajes                           ║")
    IO.puts("║    - Auto-reconexión                                     ║")
    IO.puts("║    - Monitoreo en tiempo real                            ║")
    IO.puts("║                                                           ║")
    IO.puts("╚═══════════════════════════════════════════════════════════╝")
    IO.puts("")
  end
end
