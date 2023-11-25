defmodule KartVids.Races.RacerProfile do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias KartVids.Races.{Race, Racer}
  alias KartVids.Content.Location

  schema "racer_profiles" do
    field :fastest_lap_time, :float
    field :fastest_lap_kart, :integer
    field :nickname, :string
    field :photo, :string
    field :external_racer_id, :string
    field :overall_average_lap, :float
    field :average_fastest_lap, :float
    field :lifetime_race_count, :integer

    belongs_to :fastest_lap_race, Race
    belongs_to :location, Location

    has_many :races, Racer

    timestamps()
  end

  @doc false
  def changeset(racer_profile, attrs) do
    racer_profile
    |> cast(attrs, [:location_id, :fastest_lap_time, :fastest_lap_kart, :fastest_lap_race_id, :nickname, :photo, :external_racer_id, :overall_average_lap, :average_fastest_lap, :lifetime_race_count])
    |> validate_required([:location_id, :fastest_lap_time, :fastest_lap_kart, :fastest_lap_race_id, :nickname, :photo, :overall_average_lap, :average_fastest_lap, :lifetime_race_count])
  end
end
