defmodule KartVids.Repo.Migrations.AddTextSearchColumnToRacers do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE racers ADD COLUMN nickname_vector tsvector GENERATED ALWAYS AS (to_tsvector('english', nickname)) STORED;")
    execute("CREATE INDEX racers_nickname_ts_index ON racers USING GIN (nickname_vector);")
  end

  def down do
    execute("DROP INDEX racers_nickname_ts_index;")
    execute("ALTER TABLE racers DROP COLUMN nickname_vector;")
  end
end
