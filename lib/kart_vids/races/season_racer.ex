defmodule KartVids.Races.SeasonRacer do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias KartVids.Races.Season
  alias KartVids.Races.RacerProfile

  schema "season_racers" do
    belongs_to :season, Season
    belongs_to :racer_profile, RacerProfile

    timestamps()
  end

  @doc false
  def changeset(season, attrs) do
    season
    |> cast(attrs, [:season_id, :racer_profile_id])
    |> validate_required([:season_id, :racer_profile_id])
  end
end
