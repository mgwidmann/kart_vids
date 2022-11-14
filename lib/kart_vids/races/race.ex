defmodule KartVids.Races.Race do
  use Ecto.Schema
  import Ecto.Changeset
  alias KartVids.Content.Location

  schema "races" do
    field :name, :string
    field :external_race_id, :string
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime

    belongs_to :location, Location

    timestamps()
  end

  @doc false
  def changeset(race, attrs) do
    race
    |> cast(attrs, [:external_race_id, :name, :started_at, :ended_at, :location_id])
    |> validate_required([:external_race_id, :name, :started_at, :ended_at, :location_id])
  end
end
