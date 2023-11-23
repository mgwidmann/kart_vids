defmodule KartVids.Repo.Migrations.AddHeatStatusAndHeatTypeIds do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :heat_status_id, :integer
      add :heat_type_id, :integer
    end
  end
end
