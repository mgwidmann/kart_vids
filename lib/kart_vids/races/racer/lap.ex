defmodule KartVids.Races.Racer.Lap do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Phoenix.Param, key: :lap_number}
  embedded_schema do
    field(:lap_time, :float)
    field(:amb_time, :float)
    field(:lap_number, :integer)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:lap_time, :amb_time, :lap_number])
    |> validate_required([:lap_time, :amb_time, :lap_number])
  end
end
