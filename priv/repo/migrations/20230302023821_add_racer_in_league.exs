defmodule KartVids.Repo.Migrations.AddRacerInLeague do
  use Ecto.Migration

  def change do
    create table(:season_racers) do
      add :season_id, references(:seasons, on_delete: :nothing)
      add :racer_profile_id, references(:racer_profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:season_racers, [:season_id])
    create index(:season_racers, [:racer_profile_id])
  end
end
