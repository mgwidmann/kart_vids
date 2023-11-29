defmodule KartVids.Repo.Migrations.RemoveExcessSeasonRacers do
  use Ecto.Migration
  alias KartVids.Repo

  def up do
    results =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT racer_profile_id, count(*) as racer_count FROM season_racers r WHERE r.season_id = 3 GROUP BY r.season_id, r.racer_profile_id HAVING count(*) > 1 ORDER BY racer_count DESC;",
        []
      )

    for [racer_profile_id, _count] <- results.rows do
      %Postgrex.Result{rows: [[id, _inserted_at] | _]} =
        Ecto.Adapters.SQL.query!(
          Repo,
          "SELECT id, inserted_at FROM season_racers r WHERE r.season_id = 3 AND r.racer_profile_id = $1 ORDER BY inserted_at DESC;",
          [racer_profile_id]
        )

      execute("DELETE FROM season_racers r WHERE r.id = #{id};")
    end
  end

  def down do
    # Nothing to do
  end
end
