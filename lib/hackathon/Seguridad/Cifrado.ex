defmodule Hackathon.Seguridad.Cifrado do
  @moduledoc """
  Sistema de cifrado para mensajes de chat usando AES-256-GCM
  """

  @aad "hackathon_code4future_2025"

  @doc """
  Cifra un mensaje usando AES-256-GCM
  """
  def cifrar_mensaje(contenido, clave \\ obtener_clave_maestra()) when is_binary(contenido) do
    # Generar un IV aleatorio de 12 bytes (recomendado para GCM)
    iv = :crypto.strong_rand_bytes(12)

    # Asegurar que la clave tenga 32 bytes (256 bits)
    clave_32 = normalizar_clave(clave)

    # Cifrar usando AES-256-GCM
    {texto_cifrado, tag} = :crypto.crypto_one_time_aead(
      :aes_256_gcm,
      clave_32,
      iv,
      contenido,
      @aad,
      true
    )

    # Combinar IV + Tag + Texto cifrado y codificar en Base64
    payload = iv <> tag <> texto_cifrado
    Base.encode64(payload)
  rescue
    e ->
      IO.puts("Error al cifrar: #{inspect(e)}")
      {:error, "Error de cifrado"}
  end

  @doc """
  Descifra un mensaje
  """
  def descifrar_mensaje(contenido_cifrado, clave \\ obtener_clave_maestra()) when is_binary(contenido_cifrado) do
    # Decodificar desde Base64
    payload = Base.decode64!(contenido_cifrado)

    # Extraer IV (12 bytes), Tag (16 bytes) y texto cifrado
    <<iv::binary-12, tag::binary-16, texto_cifrado::binary>> = payload

    # Normalizar clave
    clave_32 = normalizar_clave(clave)

    # Descifrar
    case :crypto.crypto_one_time_aead(
      :aes_256_gcm,
      clave_32,
      iv,
      texto_cifrado,
      @aad,
      tag,
      false
    ) do
      texto_plano when is_binary(texto_plano) ->
        {:ok, texto_plano}

      :error ->
        {:error, "Error al descifrar: datos corruptos o clave incorrecta"}
    end
  rescue
    e ->
      IO.puts("Error al descifrar: #{inspect(e)}")
      {:error, "Error de descifrado"}
  end

  @doc """
  Genera una clave de cifrado aleatoria
  """
  def generar_clave do
    :crypto.strong_rand_bytes(32) |> Base.encode64()
  end

  @doc """
  Hash de una clave para almacenamiento seguro
  """
  def hash_clave(clave) do
    :crypto.hash(:sha256, clave) |> Base.encode64()
  end

  # Funciones privadas

  defp obtener_clave_maestra do
    # En producción, esto debería venir de una variable de entorno
    # o un sistema de gestión de secretos (como HashiCorp Vault)
    System.get_env("HACKATHON_SECRET_KEY") ||
      "default_key_only_for_development_change_in_production"
  end

  defp normalizar_clave(clave) when is_binary(clave) do
    # Asegurar que la clave tenga exactamente 32 bytes
    clave_hash = :crypto.hash(:sha256, clave)
    <<clave_32::binary-32, _rest::binary>> = clave_hash <> :crypto.strong_rand_bytes(32)
    clave_32
  end
end
