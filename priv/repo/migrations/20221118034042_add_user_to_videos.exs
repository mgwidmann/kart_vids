defmodule KartVids.Repo.Migrations.AddUserToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :user_id, references(:users)
      add :is_deleted, :boolean, default: false
      add :deleted_at, :utc_datetime, default: nil
      add :youtube_url, :string
    end

    create index(:videos, [:user_id, :is_deleted])
  end
end
