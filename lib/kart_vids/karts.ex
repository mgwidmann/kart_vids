defmodule KartVids.Karts do
  @moduledoc false
  import Ecto.Query
  require Logger
  alias KartVids.Repo
  alias KartVids.Content.Location
  alias KartVids.Races.{Racer, Race, Kart}

  @large_std_dev 0.75
  @top_std_dev 25
  @min_time 15.0
  @min_karts_to_compute 10

  def compute_stats_for_kart(kart, %Location{} = location) do
    records = get_fastest_races(kart, location)

    if length(records) < @min_karts_to_compute || kart.type == :unknown do
      %{
        average_fastest_lap_time: nil,
        fastest_lap_time: nil,
        std_dev: nil,
        number_of_races: length(records),
        fastest_racer_id: nil
      }
    else
      started_at = started_at(location, kart)

      total_races =
        from(r in Racer, join: race in Race, on: r.race_id == race.id, where: r.location_id == ^location.id and r.kart_num == ^kart.kart_num and fragment("?::date >= ?", race.started_at, ^started_at), select: count(r.id))
        |> Repo.one()

      fastest_time = get_fastest_kart_time_for_type(location, kart.kart_num, kart.type)
      {_records, _dropped, mean, std_dev} = compute_stats(records, fastest_time, location)

      alternate_fastest =
        case get_fastest_races(kart, location, 5) do
          alternate_fastest = [_ | _] ->
            alternate_fastest |> quality_filter(location, kart.std_dev || @large_std_dev, fastest_time) |> List.first()

          [] ->
            nil
        end

      {racer_id, fastest_lap} =
        if alternate_fastest do
          {alternate_fastest.id, alternate_fastest.fastest_lap}
        else
          {nil, nil}
        end

      %{
        average_fastest_lap_time: mean,
        fastest_lap_time: fastest_lap,
        std_dev: std_dev,
        number_of_races: total_races,
        fastest_racer_id: racer_id
      }
    end
  end

  def get_fastest_kart_time_for_type(%Location{adult_kart_min: adult_kart_min, adult_kart_max: adult_kart_max}, kart_num, :adult) do
    from(k in Kart, join: r in Racer, on: r.id == k.fastest_racer_id, where: k.kart_num != ^kart_num and k.kart_num >= ^adult_kart_min and k.kart_num <= ^adult_kart_max, order_by: r.fastest_lap, limit: 1, select: r.fastest_lap)
    |> Repo.one()
  end

  def get_fastest_kart_time_for_type(%Location{junior_kart_min: junior_kart_min, junior_kart_max: junior_kart_max}, kart_num, :junior) do
    from(k in Kart, join: r in Racer, on: r.id == k.fastest_racer_id, where: k.kart_num != ^kart_num and k.kart_num >= ^junior_kart_min and k.kart_num <= ^junior_kart_max, order_by: r.fastest_lap, limit: 1, select: r.fastest_lap)
    |> Repo.one()
  end

  @started_at_date Date.from_iso8601!("2022-11-01")

  defp started_at(%Location{}, nil) do
    @started_at_date
  end

  defp started_at(%Location{adult_kart_reset_on: adult_kart_reset_on, junior_kart_reset_on: junior_kart_reset_on}, kart) do
    case kart.type do
      :adult ->
        adult_kart_reset_on

      :junior ->
        junior_kart_reset_on

      # Either :unknown or some other value
      _ ->
        @started_at_date
    end
    |> Kernel.||(@started_at_date)
  end

  def fastest_races(kart, location) do
    kart
    |> get_fastest_races(location)
    |> Stream.with_index(1)
    |> Enum.map(fn {racer, position} -> %{racer | position: position} end)
  end

  @max_limit 10

  def get_fastest_races(kart, location, limit \\ @max_limit)

  def get_fastest_races(nil, _location, _limit), do: []

  def get_fastest_races(kart, location, limit) when limit <= @max_limit do
    started_at = started_at(location, kart)

    from(r in Racer,
      join: race in Race,
      on: r.race_id == race.id,
      where: r.location_id == ^location.id and r.disqualify_fastest_lap == false and r.fastest_lap > ^location.min_lap_time and r.kart_num == ^kart.kart_num and fragment("?::date >= ?", race.started_at, ^started_at),
      order_by: {:asc, r.fastest_lap},
      # Top 10
      limit: ^Enum.max([@max_limit, limit * limit])
    )
    |> Repo.all()
    |> Stream.uniq_by(& &1.racer_profile_id)
    |> Enum.take(limit)
  end

  def compute_stats(records, nil, location) do
    fastest_time = Enum.min_by(records, & &1.fastest_lap).fastest_lap
    compute_stats(records, fastest_time, location)
  end

  def compute_stats(records, fastest_time, location) do
    mapper = & &1.fastest_lap

    fastest_records_time = Enum.min_by(records, mapper).fastest_lap

    std_dev = compute_std_dev(records, location, nil, mapper)

    std_dev_or_fastest_diff = Enum.max([std_dev, abs(fastest_time - fastest_records_time)])

    new_records = records |> quality_filter(location, std_dev_or_fastest_diff, fastest_time, mapper)
    mean = compute_mean(new_records, location, std_dev, fastest_time, mapper)
    # new_records = new_records |> quality_filter(location, std_dev, fastest_time, mapper)

    std_dev = compute_std_dev(new_records, location, mean, mapper)
    mean = compute_mean(new_records, location, std_dev, fastest_time, mapper)

    dropped = records -- new_records

    {new_records, dropped, mean, std_dev}
  end

  def quality_filter(records, location, std_dev, fastest_kart_time, mapper \\ fn x -> x end)

  def quality_filter(records, _location, nil, _fastest_kart_time, _mapper) do
    records
  end

  def quality_filter(records, location, std_dev, fastest_kart_time, mapper) do
    records
    |> Stream.filter(&(mapper.(&1) > location.min_lap_time && mapper.(&1) < location.max_lap_time))
    |> Enum.sort_by(&mapper.(&1))
    |> drop_larger_than_std_dev(std_dev, fastest_kart_time, mapper)
  end

  def drop_larger_than_std_dev(records, std_dev, _fastest_kart_time, mapper \\ fn x -> x end, acc_len \\ 0, acc \\ [])

  def drop_larger_than_std_dev([], _std_dev, _fastest_kart_time, _mapper, _acc_len, acc), do: Enum.reverse(acc)
  def drop_larger_than_std_dev([item], _std_dev, _fastest_kart_time, _mapper, _acc_len, acc), do: Enum.reverse([item | acc])

  def drop_larger_than_std_dev([item, next | rest], std_dev, fastest_kart_time, mapper, acc_len, acc) do
    i = mapper.(item)
    n = mapper.(next)

    # If difference too large for lower times, don't add to acc. Don't drop higher end times
    if acc_len < 15 && n - i > std_dev * (acc_len * 5 / 100 + 1) && i < fastest_kart_time do
      drop_larger_than_std_dev([next | rest], std_dev, fastest_kart_time, mapper, 0, [])
    else
      drop_larger_than_std_dev([next | rest], std_dev, fastest_kart_time, mapper, acc_len + 1, [item | acc])
    end
  end

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
  rescue
    e ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
      @large_std_dev
  end

  def compute_mean(times, location, std_dev, fastest_kart_time, mapper \\ fn x -> x end) do
    top = times |> Enum.sort_by(mapper) |> Enum.filter(&(mapper.(&1) > location.min_lap_time && mapper.(&1) < location.max_lap_time)) |> drop_larger_than_std_dev(std_dev, fastest_kart_time, mapper) |> Enum.take(@top_std_dev)
    top_count = length(top)

    top |> Stream.map(mapper) |> Enum.sum() |> Kernel./(top_count)
  end

  def minimum_lap_time(), do: @min_time
end
