defmodule KartVids.RacesFixtures do
  alias KartVids.Races.{Season, Racer}
  alias KartVids.ContentFixtures
  alias KartVids.Repo

  @moduledoc """
  This module defines test helpers for creating
  entities via the `KartVids.Races` context.
  """

  @doc """
  Generate a lap time
  """
  def generate_lap_time(), do: 20 + :rand.uniform() * 10

  @doc """
  Generate a racer nickname
  """
  def generate_nickname(), do: Enum.random(["Some Body", "Speedy", "Racentric", "Wowza", "Max Verstappen", "Redbull Racer", "F1", "Passed You", "Slick"])

  @doc """
  Generate a kart.
  """
  def kart_fixture(attrs \\ %{}) do
    {:ok, kart} =
      KartVids.Races.create_kart(
        :system,
        Enum.into(attrs, %{
          average_fastest_lap_time: 120.5,
          max_average_rpms: 42,
          fastest_lap_time: 120.5,
          kart_num: "some kart_num",
          number_of_races: 42
        })
      )

    kart
  end

  @doc """
  Generate a race.
  """
  def race_fixture(attrs \\ %{}) do
    location = attrs[:location] || ContentFixtures.location_fixture()

    started_at = attrs[:started_at] || DateTime.utc_now() |> DateTime.shift_zone!("America/New_York") |> DateTime.add(-Enum.random(0..10), :minute)

    {:ok, race} =
      KartVids.Races.create_race(
        :system,
        Enum.into(attrs, %{
          name: Enum.random(["10 Lap Race", "12 Lap Race", "5 min Junior Heat", "8 Group Race", "Qualifying Race", "AEKC Race"]),
          started_at: started_at,
          ended_at: DateTime.add(started_at, Enum.random(3..12), :minute),
          external_race_id: (:rand.uniform() * 1_000_000_000) |> trunc() |> to_string(),
          location_id: location.id
        })
      )

    race
  end

  @doc """
  Generate a racer.
  """
  def racer_fixture(attrs \\ %{}) do
    location = attrs[:location] || ContentFixtures.location_fixture()
    race = attrs[:race] || race_fixture(%{location: location})
    racer_profile = attrs[:racer_profile] || racer_profile_fixture(%{fastest_lap_race_id: race.id, location_id: location.id})

    fastest_lap = generate_lap_time()

    {:ok, racer} =
      KartVids.Races.create_racer(
        :system,
        Enum.into(attrs, %{
          average_lap: fastest_lap + :rand.uniform() * :rand.uniform() * 10,
          fastest_lap: fastest_lap,
          kart_num: Enum.random(1..60),
          nickname: generate_nickname(),
          photo: "https://userphotos.com/photos/SomeonesPhoto.jpg",
          position: Enum.random(1..8),
          race_id: race.id,
          racer_profile_id: racer_profile.id,
          race_by: :laps,
          win_by: :laptime
        })
      )

    racer
  end

  @doc """
  Generate a racer profile
  """
  def racer_profile_fixture(attrs \\ %{}) do
    {:ok, racer_profile} =
      attrs
      |> Enum.into(%{
        fastest_lap_time: generate_lap_time(),
        fastest_lap_kart: Enum.random(1..60),
        nickname: generate_nickname(),
        photo: "https://userphotos.com/photos/SomeonesPhoto.jpg",
        external_racer_id: (:rand.uniform() * 1_000_000_000) |> trunc() |> to_string(),
        fastest_lap_race_id: attrs[:fastest_lap_race_id],
        overall_average_lap: generate_lap_time(),
        average_fastest_lap: generate_lap_time(),
        location_id: attrs[:location_id]
      })
      |> KartVids.Races.create_racer_profile()

    racer_profile
  end

  def generate_start_day_and_time() do
    now = DateTime.utc_now() |> DateTime.shift_zone!("America/New_York")
    start_at = now |> DateTime.add(-3, :hour)
    {start_at |> DateTime.to_date() |> Date.day_of_week() |> Season.weekly_start_day(), start_at, start_at |> DateTime.to_time()}
    # if tests are running 12:00 - 05:00 use yesterday's date
    # if now.hour > 5 do
    #   {now |> DateTime.to_date() |> Date.day_of_week() |> Season.weekly_start_day(), now |> DateTime.add(-1, :hour) |> DateTime.to_time()}
    # else
    #   {now |> DateTime.add(-24, :hour) |> DateTime.to_date() |> Date.day_of_week() |> Season.weekly_start_day()}
    # end
  end

  @spec season_fixture(nil | maybe_improper_list | map) :: nil | [%{optional(atom) => any}] | %{optional(atom) => any}
  @doc """
  Generate a season.
  """
  def season_fixture(attrs \\ %{}) do
    location = attrs[:location] || ContentFixtures.location_fixture()

    {weekly_start_day, now, weekly_start_at} = generate_start_day_and_time()

    {:ok, season} =
      attrs
      |> Enum.into(%{
        ended: false,
        season: Enum.random(~w(winter spring summer autumn)a),
        # Exactly 4 weeks ago in days
        start_at: now |> DateTime.to_date() |> Date.add(-28),
        weekly_start_at: weekly_start_at,
        weekly_start_day: weekly_start_day,
        number_of_meetups: 8,
        daily_qualifiers: 2,
        daily_practice: true,
        driver_type: :junior,
        location_id: location.id
      })
      |> KartVids.Races.create_season()

    racers =
      for racer <- attrs[:racers] || 0..(attrs[:number_of_racers] || 20) do
        if match?(%Racer{}, racer) do
          racer
        else
          racer_fixture(%{location: location})
        end
      end

    for racer <- racers do
      season_racer_fixture(season, racer.racer_profile_id)
    end

    season
    |> Repo.preload([:location, :season_racers])
  end

  @doc """
  Generate a season racer
  """
  def season_racer_fixture(%Season{} = season, racer_profile_id) do
    {:ok, season_racer} = KartVids.Races.create_season_racer(season |> Repo.preload(:season_racers), racer_profile_id)

    season_racer
  end

  def create_season_race(name, started_at, race_by, win_by, season_racers, location) when is_binary(name) and race_by in [:laps, :minutes] and win_by in [:laptime, :position] do
    race = race_fixture(%{name: name, location: location, started_at: started_at})

    profile_ids =
      for {racer, i} <- season_racers |> Enum.with_index() do
        racer_fixture(%{
          location: location,
          nickname: racer.nickname,
          photo: racer.photo,
          position: i + 1,
          race_id: race.id,
          racer_profile_id: racer.id,
          race_by: race_by,
          win_by: win_by
        })

        racer.id
      end

    {race, profile_ids}
  end
end
