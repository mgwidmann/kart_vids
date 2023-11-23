defmodule KartVids.Repo.Migrations.AddRpmsToRacers do
  use Ecto.Migration

  def change do
    alter table(:racers) do
      add :ranking_by_rpm, :integer
      add :rpm, :integer
      add :rpm_change, :integer
    end
  end
end
