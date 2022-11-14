defmodule KartVids.Repo.Migrations.CreateRaces do
  use Ecto.Migration

  def change do
    rename table(:videos), :location, to: :location_id

    alter table(:videos) do
      add :s3_path, :string
      modify :size, :integer, from: :float
    end

    create table(:races) do
      add :external_race_id, :string, null: false
      add :name, :string, null: false
      add :started_at, :utc_datetime, null: false
      add :ended_at, :utc_datetime, null: false
      add :location_id, references(:locations)

      timestamps()
    end

    create unique_index(:races, [:id, :external_race_id])
    create index(:races, [:location_id])
  end
end
