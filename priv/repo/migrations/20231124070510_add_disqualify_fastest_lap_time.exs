defmodule KartVids.Repo.Migrations.AddDisqualifyFastestLapTime do
  use Ecto.Migration

  def change do
    alter table(:racers) do
      add :disqualify_fastest_lap, :boolean, default: false
    end
  end
end
