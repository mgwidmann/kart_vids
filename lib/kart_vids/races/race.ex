defmodule KartVids.Races.Race do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias KartVids.Content.Location
  alias KartVids.Races.Racer

  schema "races" do
    field :name, :string
    field :external_race_id, :string
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :league?, :boolean, source: :league, default: false
    field :league_type, Ecto.Enum, values: [none: 0, practice: 100, qualifier: 200, feature: 300]

    belongs_to :location, Location

    has_many :racers, Racer

    timestamps()
  end

  @doc false
  def changeset(race, attrs) do
    race
    |> cast(attrs, [:external_race_id, :name, :started_at, :ended_at, :location_id, :league?, :league_type])
    |> validate_required([:external_race_id, :name, :started_at, :ended_at, :location_id])
  end

  def league_types() do
    Ecto.Enum.mappings(__MODULE__, :league_type)
  end

  @spec league_type_none :: :none
  def league_type_none(), do: :none
  @spec league_type_practice :: :practice
  def league_type_practice(), do: :practice
  @spec league_type_qualifier :: :qualifier
  def league_type_qualifier(), do: :qualifier
  @spec league_type_feature :: :feature
  def league_type_feature(), do: :feature

  @feature_race ["aekc race"]
  @qualifying_race ["qualifying", "qualifier", "pro"]
  @league_race @feature_race ++ @qualifying_race

  def is_feature_race?(%__MODULE__{name: name}), do: is_feature_race?(name)

  def is_feature_race?(name) when is_binary(name) do
    name |> String.downcase() |> String.contains?(@feature_race)
  end

  def is_qualifying_race?(%__MODULE__{name: name}), do: is_qualifying_race?(name)

  def is_qualifying_race?(name) when is_binary(name) do
    name |> String.downcase() |> String.contains?(@qualifying_race)
  end

  def is_league_race?(%__MODULE__{name: name}), do: is_league_race?(name)

  def is_league_race?(name) when is_binary(name) do
    name |> String.downcase() |> String.contains?(@league_race)
  end
end
