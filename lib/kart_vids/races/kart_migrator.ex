defmodule KartVids.Races.KartMigrator do
  @moduledoc false
  import Ecto.Query
  require Logger
  alias KartVids.Repo
  alias KartVids.Content
  alias KartVids.Races
  alias KartVids.Races.{Kart, RacerProfile}
  alias KartVids.Karts

  @step 10

  def migrate(location_id) do
    location = Content.get_location!(location_id)
    count = Repo.one(from(k in Kart, where: k.location_id == ^location_id, select: count(k.id)))

    for s <- 0..count//@step do
      karts = Repo.all(from(k in Kart, limit: @step, offset: ^s, order_by: k.id))

      for kart <- karts do
        migrate_kart(location, kart)
      end
    end

    count = from(rp in RacerProfile, select: count(rp.id)) |> Repo.one()

    for s <- 0..count//@step do
      profiles = Repo.all(from(rp in RacerProfile, limit: @step, offset: ^s, order_by: rp.id)) |> Repo.preload(:races)

      for profile <- profiles do
        migrate_profile(location, profile)
      end
    end
  end

  def migrate_kart(location, %Kart{} = kart) do
    stats = KartVids.Karts.compute_stats_for_kart(kart, location)

    Races.update_kart(:system, kart, stats)
  end

  def migrate_profile(location, %RacerProfile{} = profile) do
    all_karts = profile.races |> Enum.map(& &1.kart_num) |> Enum.uniq()
    # Use fastest average and smallest standard deviation for all karts this user used to determine which races are quality data
    std_dev =
      from(k in Kart,
        where: k.location_id == ^location.id and k.kart_num in ^all_karts and not is_nil(k.average_fastest_lap_time) and not is_nil(k.std_dev),
        select: fragment("MAX(?)", k.std_dev)
      )
      |> Repo.one()

    fastest_race =
      profile.races
      |> Karts.quality_filter(location, std_dev, & &1.fastest_lap)
      |> Enum.sort_by(& &1.fastest_lap, :asc)
      |> List.first()

    # May not have raced since a reset was done
    if fastest_race do
      update = %{nickname: profile.nickname, photo: profile.photo, fastest_lap_time: fastest_race.fastest_lap, fastest_lap_kart: fastest_race.kart_num, fastest_lap_race_id: fastest_race.race_id}

      case Races.upsert_racer_profile(update, true) do
        {:ok, _profile} ->
          {:ok, profile.id}

        {:error, changeset} ->
          Logger.warn("Migration failure for profile #{profile.id}, Changeset failed: #{inspect(changeset)} for profile: #{inspect(profile)} and update data of #{inspect(update)}")
          nil
      end
    end
  end
end
