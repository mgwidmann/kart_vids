defmodule KartVids.Repo.Migrations.AddFastestRacerToKarts do
  use Ecto.Migration

  def change do
    alter table(:karts) do
      add :fastest_racer_id, references(:racers, on_delete: :nothing)
    end
  end
end
