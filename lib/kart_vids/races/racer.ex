defmodule KartVids.Races.Racer do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias KartVids.Races.{Race, RacerProfile}
  alias KartVids.Races.Racer.Lap

  schema "racers" do
    field :average_lap, :float
    field :fastest_lap, :float
    field :kart_num, :integer
    field :nickname, :string
    field :photo, :string
    field :position, :integer

    belongs_to :race, Race
    belongs_to :racer_profile, RacerProfile

    embeds_many :laps, Lap

    timestamps()
  end

  @doc false
  def changeset(racer, attrs) do
    racer
    |> cast(attrs, [:nickname, :photo, :kart_num, :fastest_lap, :average_lap, :position, :race_id, :racer_profile_id])
    |> cast_embed(:laps)
    |> validate_required([:nickname, :photo, :kart_num, :fastest_lap, :average_lap, :position, :race_id])
  end
end
