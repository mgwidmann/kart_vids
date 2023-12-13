defmodule KartVids.Races.Race do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias KartVids.Content.Location
  alias KartVids.Races.{Racer, Season}

  schema "races" do
    field :name, :string
    field :external_race_id, :string
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :league?, :boolean, source: :league, default: false
    field :league_type, Ecto.Enum, values: [none: 0, practice: 100, qualifier: 200, feature: 300], default: :none
    # 2 : ??
    # 3 : ??
    field :heat_status_id, :integer
    # 18  : Qualifier - Pro League   Adult Qualifier                          3
    # 29  : 12 Lap Junior - Group                                             2
    # 52  : 10 Lap Group Race                                                 3
    # 54  : 10 Lap Monaco                                                     2
    # 55  : 8 lap                                                             2
    # 56  : 10 Lap Group Race         12 Lap Race                             2, 3
    # 57  : 12 Lap Race - Event       AEKC Race (Adult Feature)               2, 3
    # 58  : 8 lap                                                             2, 3
    # 59  : 8 lap                                                             2, 3
    # 68  : 12 Lap Race                                                       2, 3
    # 69  : 12 Lap Race                                                       2, 3
    # 70  : 12 Lap Race - Event                                               2, 3
    # 71  : 12 Lap Race - Event                                               2, 3
    # 72  : 12 Lap Race                                                       2, 3
    # 73  : 12 Lap Race - Event                                               2, 3
    # 94  : 5 Min Junior Race                                                 2
    # 96  : 5 Min Junior Race - Event                                         2
    # 99  : PRIVATE Res Adult                                                 2, 3
    # 105 : 10 Lap Jr Position                                                2
    # 107 : PRIVATE Res Adult                                                 3
    # 111 : 12 Lap Private Race                                               2, 3
    # 112 : 5 Min Junior Heat                                                 2
    # 113 : 5 Min Junior Heat                                                 2
    # 116 : 5 Min Junior Heat - Event                                         2
    # 117 : 5 Min Junior Heat - Event                                         2, 3
    # 126 : 10 Lap Pro Position                                               2, 3
    # 128 : 10 Lap Group Race                                                 2, 3
    # 132 : 5 Min Junior Heat                                                 2, 3
    # 133 : 10 Lap JR Position                                                2, 3
    # 136 : 10 Lap JR Position                                                2, 3
    # 163 : 10 Lap Group Event            Adult Qualifier                     2, 3
    # 166 : AEKC Race                     Adult Feature                       2
    # 168 : 8 Lap                                                             2
    # 178 : 12 Lap Race                   Regular Adult Race
    # 179 : 12 Lap Race Group             Adult Practice/Qualifier
    # 181 : 10 Lap Junior Group                                               2
    # 204 : PRIVATE 12 Lap Race                                               2, 3
    # 212 : 5 Min Junior Heat             Regular Junior Race                 2, 3
    # 213 : PRIVATE 5 Min Junior Heat                                         2
    # 214 : 5 Min Junior Heat - Event                                         2
    # 221 : 10 Lap JR Position            Junior position qualifier?          2
    # 222 : 10 Lap Pro Position           Adult position qualifier            2, 3
    # 231 : 12 Lap Race - Event           Adult                               2, 3
    field :heat_type_id, :integer

    belongs_to :location, Location
    belongs_to :season, Season

    has_many :racers, Racer

    timestamps()
  end

  @doc false
  def changeset(race, attrs) do
    race
    |> cast(attrs, [:external_race_id, :name, :started_at, :ended_at, :location_id, :league?, :league_type, :season_id, :heat_status_id, :heat_type_id])
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

  @feature_race ["aekc race", "position"]
  @qualifying_race ["qualifying", "qualifier", "pro"]
  @league_race @feature_race ++ @qualifying_race

  def is_feature_race?(%__MODULE__{league?: true, league_type: :feature}), do: true
  def is_feature_race?(_), do: false

  def is_qualifying_race?(%__MODULE__{league?: true, league_type: :qualifier}), do: true
  def is_qualifying_race?(_), do: false

  def is_league_race?(%__MODULE__{league?: is_league}), do: is_league

  def is_league_race?(name) when is_binary(name) do
    name |> String.downcase() |> String.contains?(@league_race)
  end
end
