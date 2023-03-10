defmodule KartVids.Repo.Migrations.AddLocationIdToRacers do
  use Ecto.Migration

  def change do
    alter table(:racers) do
      add :location_id, references(:locations, on_delete: :nothing)
    end

    create index(:racers, [:location_id])
  end
end
