defmodule KartVids.Repo.Migrations.AddTimezoneToLocation do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :timezone, :string, null: false, default: "America/New_York"
    end
  end
end
