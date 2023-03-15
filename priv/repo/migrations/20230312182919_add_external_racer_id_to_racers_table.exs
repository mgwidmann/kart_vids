defmodule KartVids.Repo.Migrations.AddExternalRacerIdToRacersTable do
  use Ecto.Migration

  def change do
    alter table(:racers) do
      add :external_racer_id, :string
    end
  end
end
