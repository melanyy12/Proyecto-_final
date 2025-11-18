defmodule Hackathon.Domain.MensajeCifrado do
  @moduledoc """
  Versión cifrada del mensaje para canales privados
  """

  alias Hackathon.Seguridad.Cifrado
  alias Hackathon.Domain.Mensaje

  @doc """
  Crea un mensaje cifrado
  """
  def nuevo_cifrado(id, emisor_id, contenido, canal, tipo \\ :normal, clave \\ nil) do
    contenido_cifrado = Cifrado.cifrar_mensaje(contenido, clave)

    %Mensaje{
      id: id,
      emisor_id: emisor_id,
      contenido: contenido_cifrado,
      canal: canal,
      tipo: tipo,
      fecha: DateTime.utc_now()
    }
  end

  @doc """
  Descifra el contenido de un mensaje
  """
  def descifrar_contenido(%Mensaje{} = mensaje, clave \\ nil) do
    case Cifrado.descifrar_mensaje(mensaje.contenido, clave) do
      {:ok, contenido_descifrado} ->
        {:ok, %{mensaje | contenido: contenido_descifrado}}

      error ->
        error
    end
  end
end

