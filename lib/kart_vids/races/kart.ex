defmodule KartVids.Races.Kart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "karts" do
    field :average_fastest_lap_time, :float
    field :average_rpms, :integer
    field :fastest_lap_time, :float
    field :kart_num, :string
    field :number_of_races, :integer

    belongs_to :location, KartVids.Content.Location

    timestamps()
  end

  @doc false
  def changeset(kart, attrs) do
    kart
    |> cast(attrs, [:kart_num, :fastest_lap_time, :average_fastest_lap_time, :number_of_races, :average_rpms, :location_id])
    |> validate_required([:kart_num, :fastest_lap_time, :average_fastest_lap_time, :number_of_races, :average_rpms, :location_id])
  end
end