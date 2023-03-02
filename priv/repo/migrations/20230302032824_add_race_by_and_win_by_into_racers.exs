defmodule KartVids.Repo.Migrations.AddRaceByAndWinByIntoRacers do
  use Ecto.Migration

  def change do
    alter table(:racers) do
      add :race_by, :integer
      add :win_by, :integer
    end
  end
end
