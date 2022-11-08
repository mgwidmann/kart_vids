defmodule KartVids.Repo.Migrations.ConvertKartNumberToInteger do
  use Ecto.Migration

  def change do
    execute """
    ALTER TABLE karts ALTER COLUMN kart_num TYPE integer USING (kart_num::integer);
    """,
    """
    ALTER TABLE karts ALTER COLUMN kart_num TYPE character varying(255);
    """
  end
end
