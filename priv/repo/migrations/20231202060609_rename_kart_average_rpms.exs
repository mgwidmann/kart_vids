defmodule KartVids.Repo.Migrations.RenameKartAverageRpms do
  use Ecto.Migration

  def change do
    rename table(:karts), :average_rpms, to: :max_average_rpms
  end
end
