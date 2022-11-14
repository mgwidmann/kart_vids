defmodule KartVids.Races.Racer.Lap do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :lap_time, :float
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:lap_time])
    |> validate_required([:lap_time])
  end
end
