defmodule KartVids.Repo.Migrations.AddReferrerToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :referred_by, :citext
      remove :referrer, :citext
      add :can_refer, :boolean, default: false
    end
  end
end
