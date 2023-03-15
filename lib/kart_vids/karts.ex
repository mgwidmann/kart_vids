defmodule KartVids.Karts do
  @moduledoc false
  import Ecto.Query
  require Logger
  alias KartVids.Repo
  alias KartVids.Content.Location
  alias KartVids.Races.{Racer, Race}

  @large_std_dev 0.75
  @top_std_dev 25
  # @num_std_dev_mean 3
  # @num_std_dev 3
  @min_time 15.0
  @min_karts_to_compute 10

  def compute_stats_for_kart(kart, %Location{} = location) do
    records = get_fastest_races(kart, location)

    if length(records) < @min_karts_to_compute do
      Logger.info("Refusing to compute data when less than #{@min_karts_to_compute}, data: #{inspect(records)}")

      %{
        average_fastest_lap_time: nil,
        fastest_lap_time: nil,
        std_dev: nil,
        number_of_races: 0,
        fastest_racer_id: nil
      }
    else
      started_at = started_at(location, kart)

      total_races =
        from(r in Racer, join: race in Race, on: r.race_id == race.id, where: r.location_id == ^location.id and r.kart_num == ^kart.kart_num and fragment("?::date >= ?", race.started_at, ^started_at), select: count(r.id))
        |> Repo.one()

      {records, _dropped, mean, std_dev} = compute_stats(records, location)

      %Racer{id: racer_id, fastest_lap: fastest_time} = records |> Enum.min_by(& &1.fastest_lap)

      %{
        average_fastest_lap_time: mean,
        fastest_lap_time: fastest_time,
        std_dev: std_dev,
        number_of_races: total_races,
        fastest_racer_id: racer_id
      }
    end
  end

  defp started_at(%Location{adult_kart_reset_on: adult_kart_reset_on, junior_kart_reset_on: junior_kart_reset_on}, kart) do
    case kart.type do
      :adult ->
        adult_kart_reset_on

      :junior ->
        junior_kart_reset_on
    end
    |> Kernel.||(Date.from_iso8601!("2022-11-01"))
  end

  def fastest_races(kart, location) do
    kart
    |> get_fastest_races(location)
    |> compute_stats(location)
    |> then(fn {new_records, dropped, _mean, _std_dev} -> {new_records, dropped} end)
  end

  defp get_fastest_races(kart, location) do
    started_at = started_at(location, kart)

    from(r in Racer,
      join: race in Race,
      on: r.race_id == race.id,
      where: r.location_id == ^location.id and r.kart_num == ^kart.kart_num and fragment("?::date >= ?", race.started_at, ^started_at),
      order_by: {:asc, r.fastest_lap},
      # Some may be bad data
      limit: @top_std_dev + 10
    )
    |> Repo.all()
  end

  defp compute_stats(records, location) do
    mapper = & &1.fastest_lap

    std_dev = compute_std_dev(records, location, nil, mapper)

    new_records = records |> quality_filter(location, std_dev, mapper)
    mean = compute_mean(new_records, location, std_dev, mapper)
    # new_records = new_records |> quality_filter(location, std_dev, mapper)

    std_dev = compute_std_dev(new_records, location, mean, mapper)
    mean = compute_mean(new_records, location, std_dev, mapper)

    dropped = records -- new_records

    {new_records, dropped, mean, std_dev}
  end

  def quality_filter(records, location, std_dev, mapper \\ fn x -> x end)

  def quality_filter(records, _location, nil, _mapper) do
    records
  end

  def quality_filter(records, location, std_dev, mapper) do
    records
    |> Stream.filter(&(mapper.(&1) > location.min_lap_time && mapper.(&1) < location.max_lap_time))
    |> Enum.sort_by(&mapper.(&1))
    |> drop_larger_than_std_dev(std_dev, mapper)
  end

  def drop_larger_than_std_dev(records, std_dev, mapper \\ fn x -> x end, acc_len \\ 0, acc \\ [])

  def drop_larger_than_std_dev([], _std_dev, _mapper, _acc_len, acc), do: Enum.reverse(acc)
  def drop_larger_than_std_dev([item], _std_dev, _mapper, _acc_len, acc), do: Enum.reverse([item | acc])

  def drop_larger_than_std_dev([item, next | rest], std_dev, mapper, acc_len, acc) do
    i = mapper.(item)
    n = mapper.(next)

    # IO.puts("drop_larger? i: #{inspect(i)} n: #{inspect(n)} > #{std_dev} * (#{acc_len} * 5 / 100 + 1)")

    # If difference too large for lower times, don't add to acc. Don't drop higher end times
    if acc_len < 15 && n - i > std_dev * (acc_len * 5 / 100 + 1) do
      IO.puts("Drop at i = #{inspect(i)}")
      drop_larger_than_std_dev([next | rest], std_dev, mapper, 0, [])
    else
      drop_larger_than_std_dev([next | rest], std_dev, mapper, acc_len + 1, [item | acc])
    end
  end

  # defp get_func_std_dev(std_dev) when std_dev >= @large_std_dev do
  #   @large_std_dev
  # end

  # defp get_func_std_dev(std_dev) do
  #   std_dev * @num_std_dev
  # end

  def std_dev_cap(), do: @large_std_dev

  def compute_std_dev(times, location, mean \\ nil, mapper \\ fn x -> x end) do
    top = times |> Enum.sort_by(mapper) |> Stream.filter(&(mapper.(&1) > location.min_lap_time && mapper.(&1) < location.max_lap_time)) |> Enum.take(@top_std_dev)
    top_count = length(top)
    mean = if(mean, do: mean, else: top |> Enum.map(mapper) |> Enum.sum() |> Kernel./(top_count))

    if top_count > 1 do
      top
      |> Stream.map(mapper)
      |> Stream.map(&:math.pow(&1 - mean, 2))
      |> Enum.sum()
      |> Kernel./(top_count - 1)
      |> :math.sqrt()
      |> then(&if(&1 >= @large_std_dev, do: @large_std_dev, else: &1))
    else
      @large_std_dev
    end
  end

  def compute_mean(times, location, std_dev, mapper \\ fn x -> x end) do
    top = times |> Enum.sort_by(mapper) |> Enum.filter(&(mapper.(&1) > location.min_lap_time && mapper.(&1) < location.max_lap_time)) |> drop_larger_than_std_dev(std_dev, mapper) |> Enum.take(@top_std_dev)
    top_count = length(top)

    top |> Stream.map(mapper) |> Enum.sum() |> Kernel./(top_count)
  end

  def minimum_lap_time(), do: @min_time
end
