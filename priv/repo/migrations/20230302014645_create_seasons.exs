defmodule KartVids.Repo.Migrations.CreateSeasons do
  use Ecto.Migration

  def change do
    create table(:seasons) do
      add :season, :integer
      add :weekly_start_at, :time
      add :weekly_start_day, :integer
      add :ended, :boolean, default: false, null: false
      add :start_at, :date
      add :number_of_meetups, :integer
      add :daily_qualifiers, :integer
      add :daily_practice, :boolean
      add :driver_type, :integer
      add :location_id, references(:locations, on_delete: :nothing)

      timestamps()
    end

    create index(:seasons, [:location_id])
  end
end
