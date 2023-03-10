defmodule KartVids.Repo.Migrations.AddRacerKartIndex do
  use Ecto.Migration

  def change do
    create index(:racers, [:kart_num])
  end
end
