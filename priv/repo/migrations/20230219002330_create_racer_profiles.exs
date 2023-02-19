defmodule KartVids.Repo.Migrations.CreateRacerProfiles do
  use Ecto.Migration

  def change do
    create table(:racer_profiles) do
      add :fastest_lap_time, :float
      add :fastest_lap_kart, :integer
      add :fastest_lap_race_id, references(:races)
      add :nickname, :string
      add :photo, :string

      timestamps()
    end

    create index(:racer_profiles, [:fastest_lap_race_id])
  end
end
