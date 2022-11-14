defmodule KartVids.Repo.Migrations.CreateRacers do
  use Ecto.Migration

  def change do
    create table(:racers) do
      add :nickname, :string
      add :photo, :string
      add :kart_num, :integer
      add :fastest_lap, :float
      add :average_lap, :float
      add :position, :integer

      add :race_id, references(:races)

      add :laps, {:array, :map}, default: []

      timestamps()
    end

    create index(:racers, [:race_id])
  end
end
