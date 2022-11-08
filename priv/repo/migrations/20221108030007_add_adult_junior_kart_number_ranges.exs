defmodule KartVids.Repo.Migrations.AddAdultJuniorKartNumberRanges do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :adult_kart_min, :integer
      add :adult_kart_max, :integer
      add :junior_kart_min, :integer
      add :junior_kart_max, :integer
    end
  end
end
