defmodule KartVids.Repo.Migrations.AddAverageLapTimeToRacerProfile do
  use Ecto.Migration

  def change do
    alter table(:racer_profiles) do
      add :overall_average_lap, :float
      add :average_fastest_lap, :float
      add :lifetime_race_count, :integer
      add :location_id, references(:locations, on_delete: :nothing)
    end
  end
end
