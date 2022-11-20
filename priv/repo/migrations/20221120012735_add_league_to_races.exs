defmodule KartVids.Repo.Migrations.AddLeagueToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :league, :boolean, default: false
    end

    create index(:races, [:league, :started_at])
    create index(:races, [:league])
  end
end
