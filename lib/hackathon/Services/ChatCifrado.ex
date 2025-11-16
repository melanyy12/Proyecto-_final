defmodule Hackathon.Services.ChatCifrado do
  @moduledoc """
  Extensión del sistema de chat para soportar mensajes cifrados
  """

  alias Hackathon.Services.SistemaChat
  alias Hackathon.Domain.MensajeCifrado

  @doc """
  Envía un mensaje cifrado a un canal
  """
  def enviar_mensaje_cifrado(emisor_id, contenido, canal, clave \\ nil) do
    id = generar_id()
    mensaje = MensajeCifrado.nuevo_cifrado(id, emisor_id, contenido, canal, :cifrado, clave)

    # Guardar en persistencia
    Task.start(fn ->
      Hackathon.Adapters.Persistencia.RepositorioMensajes.guardar(mensaje)
    end)

    # Notificar (el contenido ya está cifrado)
    GenServer.call(SistemaChat, {:mensaje_interno, mensaje})

    {:ok, mensaje}
  end

  @doc """
  Obtiene y descifra mensajes de un canal
  """
  def obtener_historial_descifrado(canal, clave \\ nil) do
    case SistemaChat.obtener_historial(canal) do
      {:ok, mensajes} ->
        mensajes_descifrados =
          Enum.map(mensajes, fn mensaje ->
            if mensaje.tipo == :cifrado do
              case MensajeCifrado.descifrar_contenido(mensaje, clave) do
                {:ok, descifrado} -> descifrado
                _ -> %{mensaje | contenido: "[Mensaje cifrado - clave incorrecta]"}
              end
            else
              mensaje
            end
          end)

        {:ok, mensajes_descifrados}

      error ->
        error
    end
  end

  defp generar_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end
end
