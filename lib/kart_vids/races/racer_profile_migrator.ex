defmodule KartVids.Races.RacerProfileMigrator do
  @moduledoc false
  import Ecto.Query
  require Logger
  alias KartVids.Repo
  alias KartVids.Races
  alias KartVids.Content
  alias KartVids.Content.Location
  alias KartVids.Races.RacerProfile

  @step 10

  def migrate(location_id) do
    count = Repo.one(from(p in RacerProfile, select: count(p.id)))
    location = Content.get_location!(location_id)

    for s <- 0..count//@step do
      profiles = Repo.all(from(rp in RacerProfile, limit: @step, offset: ^s, order_by: rp.id)) |> Repo.preload(:races)

      for profile <- profiles do
        migrate_profile(location, profile)
      end
    end
  end

  def migrate_profile(%Location{min_lap_time: min_lap_time} = location, %RacerProfile{} = profile) do
    profile = migrate_profile_races(profile, location)

    fastest_lap_time =
      if profile.fastest_lap_time <= min_lap_time do
        profile.races
        |> Stream.reject(&(&1.fastest_lap <= min_lap_time))
        |> Stream.map(& &1.fastest_lap)
        |> Enum.min(&<=/2, fn -> raise "Unable to migrate profile: #{inspect(profile, pretty: true)}" end)
      else
        profile.fastest_lap_time
      end

    overall_average_lap_count = Stream.reject(profile.races, &(&1.average_lap <= min_lap_time)) |> Enum.count()

    overall_average_lap =
      if overall_average_lap_count > 0 do
        profile.races
        |> Stream.reject(&(&1.average_lap <= min_lap_time))
        |> Stream.map(& &1.average_lap)
        |> Enum.sum()
        |> Kernel./(overall_average_lap_count)
      else
        fastest_lap_time
      end

    average_fastest_lap_count = Stream.reject(profile.races, &(&1.fastest_lap <= min_lap_time)) |> Enum.count()

    average_fastest_lap =
      if average_fastest_lap_count > 0 do
        profile.races
        |> Stream.reject(&(&1.fastest_lap <= min_lap_time))
        |> Stream.map(& &1.fastest_lap)
        |> Enum.sum()
        |> Kernel./(average_fastest_lap_count)
      else
        fastest_lap_time
      end

    lifetime_race_count = Enum.min([overall_average_lap_count, average_fastest_lap_count])

    Races.upsert_racer_profile(
      %{
        nickname: profile.nickname,
        photo: profile.photo,
        external_racer_id: profile.external_racer_id,
        overall_average_lap: overall_average_lap,
        average_fastest_lap: average_fastest_lap,
        lifetime_race_count: lifetime_race_count,
        fastest_lap_time: fastest_lap_time,
        # All racers are at the same location
        location_id: location.id
      },
      true
    )
  end

  def migrate_profile_races(%RacerProfile{races: races} = profile, %Location{min_lap_time: min_lap_time}) do
    races =
      for race <- races do
        laps = Enum.reject(race.laps, &(&1.lap_time <= min_lap_time))
        # A single lap of zero or something shouldn't be updated
        if length(laps) >= 1 do
          actual_fastest_lap =
            laps
            |> Enum.min_by(& &1.lap_time, &<=/2, fn -> :no_minimum end)

          if actual_fastest_lap == :no_minimum do
            raise "Cannot find minimum lap time for race: #{inspect(race)}"
          end

          {:ok, race} = Races.update_racer(:system, race, %{fastest_lap: actual_fastest_lap.lap_time})
          race
        else
          race
        end
      end

    %{profile | races: races}
  end
end
