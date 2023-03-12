defmodule KartVids.Repo.Migrations.AddExternalRacerIdToRacerProfile do
  use Ecto.Migration

  def change do
    alter table(:racer_profiles) do
      add :external_racer_id, :string
    end

    create index(:racer_profiles, :external_racer_id)
  end
end
