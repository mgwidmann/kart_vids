defmodule KartVids.Repo.Migrations.AddKartTypeResetToLocation do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :adult_kart_reset_on, :date
      add :junior_kart_reset_on, :date
    end
  end
end
