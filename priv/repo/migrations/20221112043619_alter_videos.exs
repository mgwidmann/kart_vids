defmodule KartVids.Repo.Migrations.AlterVideos do
  use Ecto.Migration

  def change do
    rename table(:videos), :size_mb, to: :size

    alter table(:videos) do
      add :mime_type, :string
    end
  end
end
