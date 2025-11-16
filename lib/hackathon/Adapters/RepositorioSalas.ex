defmodule Hackathon.Adapters.Persistencia.RepositorioSalas do
  @archivo "data/salas.txt"

  def guardar(sala) do
    contenido = serializar(sala)
    File.mkdir_p!("data")
    File.write!(@archivo, contenido <> "\n", [:append])
    :ok
  rescue
    e -> {:error, "Error al guardar: #{inspect(e)}"}
  end

  def listar_todas do
    if File.exists?(@archivo) do
      salas =
        File.read!(@archivo)
        |> String.split("\n", trim: true)
        |> Enum.map(&deserializar/1)
        |> Enum.reject(&is_nil/1)
      {:ok, salas}
    else
      {:ok, []}
    end
  rescue
    e -> {:error, "Error al leer: #{inspect(e)}"}
  end

  def obtener(sala_id) do
    case listar_todas() do
      {:ok, salas} ->
        case Enum.find(salas, fn s -> s.id == sala_id end) do
          nil -> {:error, :no_encontrado}
          sala -> {:ok, sala}
        end
      error -> error
    end
  end

  def actualizar(sala) do
    case listar_todas() do
      {:ok, salas} ->
        salas_actualizadas =
          Enum.map(salas, fn s ->
            if s.id == sala.id, do: sala, else: s
          end)
        reescribir_archivo(salas_actualizadas)
      error -> error
    end
  end

  def listar_publicas do
    case listar_todas() do
      {:ok, salas} ->
        publicas = Enum.filter(salas, fn s -> s.publica and s.activa end)
        {:ok, publicas}
      error -> error
    end
  end

  def eliminar(sala_id) do
    case listar_todas() do
      {:ok, salas} ->
        salas_filtradas = Enum.reject(salas, fn s -> s.id == sala_id end)
        reescribir_archivo(salas_filtradas)
        {:ok, :eliminado}
      error -> error
    end
  end

  defp reescribir_archivo(salas) do
    contenido = Enum.map_join(salas, "\n", &serializar/1)
    File.write!(@archivo, contenido <> "\n")
    :ok
  rescue
    e -> {:error, "Error al actualizar: #{inspect(e)}"}
  end

  defp serializar(sala) do
    miembros_str = Enum.join(sala.miembros, ",")
    "#{sala.id}|#{sala.nombre}|#{sala.descripcion}|#{sala.creador_id}|#{sala.tipo}|#{miembros_str}|#{sala.publica}|#{sala.activa}"
  end

  defp deserializar(linea) do
    case String.split(linea, "|") do
      [id, nombre, descripcion, creador_id, tipo, miembros_str, publica, activa] ->
        miembros = if miembros_str == "", do: [], else: String.split(miembros_str, ",")

        %Hackathon.Domain.Sala{
          id: id,
          nombre: nombre,
          descripcion: descripcion,
          creador_id: creador_id,
          tipo: String.to_atom(tipo),
          miembros: miembros,
          publica: publica == "true",
          activa: activa == "true",
          fecha_creacion: nil
        }
      _ -> nil
    end
  end
end
