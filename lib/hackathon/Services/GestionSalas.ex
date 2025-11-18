defmodule Hackathon.Services.GestionSalas do
  @moduledoc """
  Servicio para gestionar salas temáticas de discusión
  """

  alias Hackathon.Domain.Sala
  alias Hackathon.Adapters.Persistencia.RepositorioSalas

  @doc """
  Crea una nueva sala temática
  """
  def crear_sala(attrs) do
    with {:ok, _} <- validar_nombre(attrs[:nombre]),
         sala <- Sala.nueva(
           generar_id(),
           attrs.nombre,
           attrs.creador_id,
           attrs[:descripcion] || "",
           attrs[:tipo] || :general
         ),
         :ok <- RepositorioSalas.guardar(sala) do
      {:ok, sala}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Permite a un usuario unirse a una sala
  """
  def unirse_a_sala(sala_id, usuario_id) do
    with {:ok, sala} <- RepositorioSalas.obtener(sala_id),
         {:ok, sala_actualizada} <- Sala.agregar_miembro(sala, usuario_id),
         :ok <- RepositorioSalas.actualizar(sala_actualizada) do
      {:ok, sala_actualizada}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Remueve un usuario de una sala
  """
  def salir_de_sala(sala_id, usuario_id) do
    with {:ok, sala} <- RepositorioSalas.obtener(sala_id),
         sala_actualizada <- Sala.remover_miembro(sala, usuario_id),
         :ok <- RepositorioSalas.actualizar(sala_actualizada) do
      {:ok, sala_actualizada}
    else
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Lista todas las salas públicas y activas
  """
  def listar_salas_publicas do
    RepositorioSalas.listar_publicas()
  end

  @doc """
  Lista todas las salas
  """
  def listar_todas do
    RepositorioSalas.listar_todas()
  end

  @doc """
  Obtiene una sala por su ID
  """
  def obtener_sala(sala_id) do
    RepositorioSalas.obtener(sala_id)
  end

  @doc """
  Desactiva una sala (solo el creador)
  """
  def desactivar_sala(sala_id, usuario_id) do
    with {:ok, sala} <- RepositorioSalas.obtener(sala_id),
         true <- sala.creador_id == usuario_id,
         sala_desactivada <- Sala.desactivar(sala),
         :ok <- RepositorioSalas.actualizar(sala_desactivada) do
      {:ok, sala_desactivada}
    else
      false -> {:error, "Solo el creador puede desactivar la sala"}
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Elimina una sala completamente
  """
  def eliminar_sala(sala_id) do
    RepositorioSalas.eliminar(sala_id)
  end

  # Funciones privadas

  defp validar_nombre(nil), do: {:error, "Nombre requerido"}
  defp validar_nombre(""), do: {:error, "Nombre no puede estar vacío"}

  defp validar_nombre(nombre) when is_binary(nombre) do
    cond do
      String.length(String.trim(nombre)) < 3 ->
        {:error, "Nombre debe tener al menos 3 caracteres"}

      String.length(String.trim(nombre)) > 50 ->
        {:error, "Nombre demasiado largo (máximo 50 caracteres)"}

      true ->
        {:ok, :valido}
    end
  end

  defp validar_nombre(_), do: {:error, "Nombre inválido"}

  defp generar_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end
end
