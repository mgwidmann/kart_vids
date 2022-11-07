defmodule KartVids.Repo.Migrations.CreateKarts do
  use Ecto.Migration

  def change do
    create table(:karts) do
      add :kart_num, :string
      add :fasest_lap_time, :float
      add :average_fastest_lap_time, :float
      add :number_of_races, :integer
      add :average_rpms, :integer
      add :location, references(:locations, on_delete: :nothing)

      timestamps()
    end

    create index(:karts, [:location])
  end
end
