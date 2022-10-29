defmodule KartVids.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :location, :string
      add :duration_seconds, :integer
      add :size_mb, :float
      add :name, :string
      add :description, :text
      add :recorded_on, :utc_datetime

      timestamps()
    end
  end
end
