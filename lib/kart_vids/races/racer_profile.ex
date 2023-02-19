defmodule KartVids.Races.RacerProfile do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias KartVids.Races.{Race, Racer}

  schema "racer_profiles" do
    field :fastest_lap_time, :float
    field :fastest_lap_kart, :integer
    field :nickname, :string
    field :photo, :string

    belongs_to :fastest_lap_race, Race

    has_many :races, Racer

    timestamps()
  end

  @doc false
  def changeset(racer_profile, attrs) do
    racer_profile
    |> cast(attrs, [:fastest_lap_time, :fastest_lap_kart, :fastest_lap_race_id, :nickname, :photo])
    |> validate_required([:fastest_lap_time, :fastest_lap_kart, :fastest_lap_race_id, :nickname, :photo])
  end
end
