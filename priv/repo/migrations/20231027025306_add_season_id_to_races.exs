defmodule KartVids.Repo.Migrations.AddSeasonIdToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :season_id, references(:seasons, on_delete: :nothing)
    end

    create index(:races, [:season_id])
  end
end
