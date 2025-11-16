defmodule Hackathon.Domain.Sala do
  @moduledoc """
  Entidad que representa una sala temática de discusión
  """

  @enforce_keys [:id, :nombre, :creador_id]
  defstruct [
    :id,
    :nombre,
    :descripcion,
    :creador_id,
    :tipo,
    miembros: [],
    publica: true,
    fecha_creacion: nil,
    activa: true
  ]

  def nueva(id, nombre, creador_id, descripcion \\ "", tipo \\ :general) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      creador_id: creador_id,
      descripcion: descripcion,
      tipo: tipo,
      fecha_creacion: DateTime.utc_now()
    }
  end

  def agregar_miembro(%__MODULE__{} = sala, usuario_id) do
    if usuario_id in sala.miembros do
      {:error, "Usuario ya está en la sala"}
    else
      {:ok, %{sala | miembros: [usuario_id | sala.miembros]}}
    end
  end

  def remover_miembro(%__MODULE__{} = sala, usuario_id) do
    nuevos_miembros = Enum.reject(sala.miembros, fn id -> id == usuario_id end)
    %{sala | miembros: nuevos_miembros}
  end

  def desactivar(%__MODULE__{} = sala) do
    %{sala | activa: false}
  end
end
