defmodule KartVids.Repo.Migrations.MigrateLocationIdToRacers do
  use Ecto.Migration

  def up do
    # Only one location exists currently so this will just be its ID
    execute("UPDATE racers SET location_id = (SELECT id from locations LIMIT 1);")
  end

  def down do
    execute("UPDATE racers SET location_id = null;")
  end
end
