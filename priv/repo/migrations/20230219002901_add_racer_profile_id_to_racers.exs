defmodule KartVids.Repo.Migrations.AddRacerProfileIdToRacers do
  use Ecto.Migration

  def change do
    alter table(:racers) do
      add :racer_profile_id, references(:racer_profiles), default: nil
    end

    create index(:racers, [:racer_profile_id])
  end
end
