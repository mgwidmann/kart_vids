defmodule KartVids.Races.Season do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias KartVids.Content.Location
  alias KartVids.Races.{RacerProfile, SeasonRacer}

  schema "seasons" do
    field :ended, :boolean, default: false
    field :season, Ecto.Enum, values: [winter: 100, spring: 200, summer: 300, autumn: 400]
    field :start_at, :date
    field :weekly_start_at, :time
    field :weekly_start_day, Ecto.Enum, values: [monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7]
    field :number_of_meetups, :integer
    field :daily_qualifiers, :integer
    field :daily_practice, :boolean
    field :driver_type, Ecto.Enum, values: [junior: 100, adult: 200]

    belongs_to :location, Location
    many_to_many :season_racers, RacerProfile, join_through: SeasonRacer

    timestamps()
  end

  @doc false
  def changeset(season, attrs) do
    season
    |> cast(attrs, [:season, :weekly_start_at, :weekly_start_day, :ended, :start_at, :number_of_meetups, :daily_qualifiers, :daily_practice, :location_id])
    |> validate_required([:season, :weekly_start_at, :weekly_start_day, :ended, :start_at, :number_of_meetups, :daily_qualifiers, :daily_practice, :location_id])
  end

  def seasons() do
    Ecto.Enum.mappings(__MODULE__, :season)
  end

  def weekly_start_days() do
    Ecto.Enum.mappings(__MODULE__, :weekly_start_day)
  end

  def weekly_start_day(number) when number >= 1 and number <= 7 do
    inverted = for({k, v} <- weekly_start_days(), into: %{}, do: {v, k})
    inverted[number]
  end

  def driver_types() do
    Ecto.Enum.mappings(__MODULE__, :driver_type)
  end
end
