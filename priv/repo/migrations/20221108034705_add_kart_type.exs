defmodule KartVids.Repo.Migrations.AddKartType do
  use Ecto.Migration

  def change do
    alter table(:karts) do
      add :type, :string
    end
  end
end
