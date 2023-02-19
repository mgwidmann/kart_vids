defmodule KartVids.Repo.Migrations.AddTextSearchColumnToRacerProfile do
  use Ecto.Migration

  def up do
    execute(
      "ALTER TABLE racer_profiles ADD COLUMN nickname_vector tsvector GENERATED ALWAYS AS (to_tsvector('english', nickname)) STORED;"
    )

    execute(
      "CREATE INDEX racer_profiles_nickname_ts_index ON racer_profiles USING GIN (nickname_vector);"
    )
  end

  def down do
    execute("DROP INDEX racer_profiles_nickname_ts_index;")
    execute("ALTER TABLE racer_profiles DROP COLUMN nickname_vector;")
  end
end
