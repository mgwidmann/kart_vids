defmodule KartVids.Races.Kart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "karts" do
    field :average_fastest_lap_time, :float
    field :average_rpms, :integer
    field :fasest_lap_time, :float
    field :kart_num, :string
    field :number_of_races, :integer
    field :location, :id

    timestamps()
  end

  @doc false
  def changeset(kart, attrs) do
    kart
    |> cast(attrs, [:kart_num, :fasest_lap_time, :average_fastest_lap_time, :number_of_races, :average_rpms])
    |> validate_required([:kart_num, :fasest_lap_time, :average_fastest_lap_time, :number_of_races, :average_rpms])
  end
end
