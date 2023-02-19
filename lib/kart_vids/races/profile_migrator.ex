defmodule KartVids.Races.ProfileMigrator do
  @moduledoc false
  import Ecto.Query
  alias KartVids.Repo
  alias KartVids.Races
  alias KartVids.Races.{Race, Racer}

  @step 10

  def migrate(location_id) do
    count = Repo.one(from r in Race, select: count(r.id))

    for s <- 1..count//@step do
      all_races =
        from(r in Race,
          join: z in Racer,
          on: z.race_id == r.id,
          where: r.location_id == ^location_id and is_nil(z.racer_profile_id),
          limit: @step,
          offset: ^s
        )
        |> Repo.all()
        |> Repo.preload(:racers)

      for race <- all_races, racer <- race.racers do
        {:ok, profile} =
          Races.upsert_racer_profile(%{
            nickname: racer.nickname,
            photo: racer.photo,
            fastest_lap_time: racer.fastest_lap,
            fastest_lap_kart: racer.kart_num,
            fastest_lap_race_id: race.id
          })

        Races.update_racer(:system, racer, %{racer_profile_id: profile.id})
      end
    end
  end
end
