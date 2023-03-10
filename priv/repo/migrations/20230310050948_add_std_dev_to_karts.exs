defmodule KartVids.Repo.Migrations.AddStdDevToKarts do
  use Ecto.Migration

  def change do
    alter table(:karts) do
      add :std_dev, :float
    end
  end
end
