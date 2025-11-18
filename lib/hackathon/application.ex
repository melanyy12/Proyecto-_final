defmodule Hackathon.Application do
  @moduledoc """
  Aplicación OTP con supervisión de servicios críticos
  Incluye soporte para nodos distribuidos
  """
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      # Registry para canales de chat dinámicos
      {Registry, keys: :unique, name: Hackathon.CanalRegistry},

      # Sistema de Chat principal (GLOBAL para distribución)
      {Hackathon.Services.SistemaChat, []},

      # Monitor de métricas
      {Hackathon.Metricas.Monitor, []},

      # Sistema de Nodos Distribuidos
      {Hackathon.Distribucion.Nodo, []},

      # Sistema de Auto-Reconexión
      {Hackathon.Distribucion.AutoReconexion, []},

      # Dashboard distribuido
      {Hackathon.Distribucion.Dashboard, []},

      # Notificador de eventos
      {Hackathon.Distribucion.Notificador, []},

      # Supervisor dinámico para canales individuales
      {DynamicSupervisor, strategy: :one_for_one, name: Hackathon.CanalesSupervisor},

      # Tarea periódica para limpiar sesiones expiradas
      {Task, fn -> iniciar_limpieza_periodica() end}
    ]

    opts = [strategy: :one_for_one, name: Hackathon.Supervisor]

    Logger.info(" Iniciando aplicación Hackathon...")
    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        Logger.info("✅ Aplicación iniciada correctamente")
        Logger.info("📡 Nodo: #{Node.self()}")
        {:ok, pid}
      error ->
        Logger.error(" Error al iniciar aplicación: #{inspect(error)}")
        error
    end
  end

  defp iniciar_limpieza_periodica do
    # Limpiar sesiones cada hora
    Process.sleep(3600 * 1000)
    Hackathon.Services.Autenticacion.limpiar_sesiones_expiradas()
    iniciar_limpieza_periodica()
  end
end
