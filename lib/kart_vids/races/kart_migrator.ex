defmodule KartVids.Races.KartMigrator do
  @moduledoc false
  import Ecto.Query
  alias KartVids.Repo
  alias KartVids.Races
  alias KartVids.Races.{Kart, Listener}

  @step 10

  def migrate(location_id) do
    count = Repo.one(from k in Kart, where: k.location_id == ^location_id, select: count(k.id))

    for s <- 0..count//@step do
      karts = Repo.all(from(k in Kart, limit: @step, offset: ^s, order_by: k.id))

      for kart <- karts do
        times = Races.get_fastest_lap_times_for_kart(location_id, kart.kart_num)
        std_dev = Listener.compute_std_dev(times)
        mean = Listener.compute_mean(times, std_dev)
        std_dev = Listener.compute_std_dev(times, mean)

        func_std_dev =
          if std_dev >= 0.75 do
            std_dev
          else
            std_dev * 3
          end

        fastest_time = times |> Enum.filter(&(&1 > 10.0)) |> Enum.sort() |> Enum.filter(&(&1 > mean - func_std_dev)) |> List.first()

        {:ok, _kart} =
          Races.update_kart(
            :system,
            kart,
            %{
              average_fastest_lap_time: mean,
              fastest_lap_time: fastest_time,
              std_dev: std_dev,
              number_of_races: length(times)
            }
          )
      end
    end
  end
end
