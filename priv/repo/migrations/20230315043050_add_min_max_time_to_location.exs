defmodule KartVids.Repo.Migrations.AddMinMaxTimeToLocation do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :min_lap_time, :float
      add :max_lap_time, :float
    end
  end
end
