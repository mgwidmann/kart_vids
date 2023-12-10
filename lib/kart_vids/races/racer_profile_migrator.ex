defmodule KartVids.Races.RacerProfileMigrator do
  @moduledoc false
  import Ecto.Query
  require Logger
  alias KartVids.Repo
  alias KartVids.Races
  alias KartVids.Races.Racer
  alias KartVids.Races.SeasonRacer
  alias KartVids.Content
  alias KartVids.Content.Location
  alias KartVids.Races.RacerProfile

  @step 10

  def migrate(location_id) do
    count = Repo.one(from(p in RacerProfile, select: count(p.id)))
    location = Content.get_location!(location_id)

    for s <- 0..count//@step do
      profiles =
        Repo.all(from(rp in RacerProfile, limit: @step, offset: ^s, order_by: rp.id))
        |> remove_duplicate_profiles()
        |> Repo.preload(:races)

      for profile <- profiles do
        migrate_profile(location, profile)
      end
    end
  end

  def remove_duplicate_profiles(profiles, return_profiles \\ [])

  def remove_duplicate_profiles(%RacerProfile{} = profile, return_profiles), do: remove_duplicate_profiles([profile], return_profiles)
  def remove_duplicate_profiles([], return_profiles), do: Enum.reverse(return_profiles)

  def remove_duplicate_profiles([profile | other_profiles], return_profiles) do
    dupes_with_original =
      from(p in RacerProfile, join: p2 in RacerProfile, on: p.external_racer_id == p2.external_racer_id, select: p2, where: p.id == ^profile.id, order_by: p2.inserted_at)
      |> Repo.all()

    if length(dupes_with_original) > 1 do
      [original | dupes] = dupes_with_original

      additional_races =
        for dup <- dupes do
          from(r in Racer, where: r.racer_profile_id == ^dup.id)
          |> Repo.update_all(set: [racer_profile_id: original.id])
          |> elem(0)
        end
        |> Enum.sum()

      dup_ids = Enum.map(dupes, & &1.id)

      from(s in SeasonRacer, where: s.racer_profile_id in ^dup_ids)
      |> Repo.delete_all()

      Races.update_racer_profile(original, %{lifetime_race_count: original.lifetime_race_count + additional_races})

      for dup <- dupes, do: Races.delete_racer_profile(dup)

      remove_duplicate_profiles(other_profiles, return_profiles)
    else
      remove_duplicate_profiles(other_profiles, [profile | return_profiles])
    end
  end

  defmodule CannotMigrateProfile do
    defexception message: "", racer_profile_id: nil
  end

  def migrate_profile(%Location{min_lap_time: min_lap_time} = location, %RacerProfile{} = profile) do
    profile = migrate_profile_races(profile, location)

    fastest_lap_time =
      profile.races
      |> Stream.reject(&(&1.fastest_lap <= min_lap_time || &1.disqualify_fastest_lap))
      |> Stream.map(& &1.fastest_lap)
      |> Enum.min(&<=/2, fn ->
        raise CannotMigrateProfile, message: "Unable to migrate profile: #{inspect(profile, pretty: true)}", racer_profile_id: profile.id
      end)

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
  rescue
    e in CannotMigrateProfile ->
      Logger.warning(e)
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
