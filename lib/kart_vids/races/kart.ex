defmodule KartVids.Races.Kart do
  use Ecto.Schema
  import Ecto.Changeset
  alias KartVids.Content.Location
  alias KartVids.Races.Racer

  require Logger

  schema "karts" do
    field :average_fastest_lap_time, :float
    field :max_average_rpms, :integer
    field :fastest_lap_time, :float
    field :std_dev, :float
    field :kart_num, :integer
    field :number_of_races, :integer
    field :type, Ecto.Enum, values: [:adult, :junior, :unknown]

    belongs_to :fastest_racer, Racer

    belongs_to :location, Location

    timestamps()
  end

  @doc false
  def changeset(kart, attrs) do
    kart
    |> cast(attrs, [:kart_num, :fastest_lap_time, :average_fastest_lap_time, :number_of_races, :max_average_rpms, :type, :std_dev, :location_id, :fastest_racer_id])
    |> validate_required([:kart_num, :number_of_races, :max_average_rpms, :type, :location_id])
  end

  def kart_type(num, %Location{adult_kart_min: min, adult_kart_max: max}) when is_number(num) and num >= min and num <= max, do: :adult
  def kart_type(num, %Location{junior_kart_min: min, junior_kart_max: max}) when is_number(num) and num >= min and num <= max, do: :junior
  def kart_type(_, _), do: :unknown
end
