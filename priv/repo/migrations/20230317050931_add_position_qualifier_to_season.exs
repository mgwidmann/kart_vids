defmodule KartVids.Repo.Migrations.AddPositionQualifierToSeason do
  use Ecto.Migration

  def change do
    alter table(:seasons) do
      add :position_qualifier, :boolean, default: false
    end
  end
end
