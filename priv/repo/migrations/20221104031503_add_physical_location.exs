defmodule KartVids.Repo.Migrations.AddPhysicalLocation do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string, null: false
      add :street, :string, null: false
      add :street_2, :string
      add :city, :string, null: false
      add :state, :string, null: false
      add :code, :string
      add :country, :string

      timestamps()
    end

    alter table(:videos) do
      remove :location, :string
      add :location, references(:locations), from: :string
      add :file, :string
    end
  end
end
