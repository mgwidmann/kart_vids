defmodule KartVids.Repo.Migrations.CreateKarts do
  use Ecto.Migration

  def change do
    create table(:karts) do
      add :kart_num, :string
      add :fastest_lap_time, :float
      add :average_fastest_lap_time, :float
      add :number_of_races, :integer
      add :average_rpms, :integer
      add :location_id, references(:locations, on_delete: :nothing)

      timestamps()
    end

    create index(:karts, [:location_id, :kart_num])
  end
end
