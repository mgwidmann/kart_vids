defmodule KartVids.Repo.Migrations.AddLeagueType do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :league_type, :integer
    end

    create index(:races, [:external_race_id])
  end
end
