defmodule KartVids.Races.Listener do
  use WebSockex
  require Logger
  alias KartVids.Races
  alias KartVids.Races.Race
  alias KartVids.Races.Kart
  alias KartVids.Content.Location

  defmodule Config do
    @moduledoc false
    @type t :: %Config{location_id: nil | pos_integer(), location: Location.t()}
    defstruct location_id: nil, location: nil
  end

  defmodule State do
    @moduledoc false
    @type t :: %State{
            config: Config.t(),
            current_race: nil | Stirng.t(),
            race_name: nil | String.t(),
            fastest_speed_level: nil | pos_integer(),
            speed_level: nil | pos_integer(),
            racers: list(Racer.t()),
            scoreboard: nil | map(),
            last_timestamp: nil | String.t(),
            win_by: nil | String.t()
          }
    defstruct config: %Config{}, current_race: nil, current_race_started_at: nil, race_name: nil, fastest_speed_level: nil, speed_level: nil, racers: [], scoreboard: nil, last_timestamp: nil, win_by: nil
  end

  defmodule Racer do
    @moduledoc false
    @derive {Phoenix.Param, key: :nickname}
    @type t :: %Racer{nickname: String.t(), photo: String.t(), kart_num: pos_integer(), fastest_lap: float(), average_lap: float(), last_lap: float(), position: pos_integer(), laps: list(map())}
    defstruct nickname: "", photo: "", kart_num: -1, fastest_lap: 999.99, average_lap: 999.99, last_lap: 999.99, position: 99, laps: []
  end

  @fastest_speed_level 1
  @min_lap_time 15.0
  @max_lap_time 30.0

  @spec whereis(number | Location.t()) :: pid() | nil
  def whereis(%Location{id: id}), do: whereis(id)

  def whereis(location_id) when is_number(location_id) do
    case Registry.lookup(KartVids.Registry, {__MODULE__, location_id}) do
      [{pid, _} | _] -> pid
      [] -> nil
    end
  end

  @spec subscribe(number | Location.t()) :: :ok | {:error, {:already_registered, pid}}
  def subscribe(%Location{id: id}), do: subscribe(id)

  def subscribe(location_id) when is_number(location_id) do
    location_id
    |> topic_name()
    |> KartVidsWeb.Endpoint.subscribe()
  end

  ### Server functions

  @spec start_link(Location.t()) :: {:error, any} | {:ok, pid}
  def start_link(%Location{} = location) do
    WebSockex.start_link(
      "ws://autobahn-livescore.herokuapp.com/?track=1&location=aisdulles",
      __MODULE__,
      location,
      name: via_tuple(location.id)
    )
  end

  @doc false
  def child_spec(%Location{} = location) do
    %{
      id: {KartVids.Races.Listener, location},
      start: {KartVids.Races.Listener, :start_link, [location]},
      restart: :transient,
      # handle_stopped_children won't be invoked without this
      ephemeral?: true
    }
    |> Supervisor.child_spec([])
  end

  @doc false
  def child_spec(conn_info, %Location{} = location) do
    %{
      id: {KartVids.Races.Listener, location},
      start: {KartVids.Races.Listener, :start_link, [conn_info, location]},
      restart: :transient,
      # handle_stopped_children won't be invoked without this
      ephemeral?: true
    }
    |> Supervisor.child_spec([])
  end

  def via_tuple(location_id) do
    {:via, Registry, {KartVids.Registry, {__MODULE__, location_id}}}
  end

  def handle_connect(_conn, %Location{} = location) do
    Logger.info("Connected to websocket for location #{location.id}!")

    {:ok, %State{config: %Config{location_id: location.id, location: location}}}
  end

  def handle_disconnect(connection_status, %State{} = state) do
    Logger.warn("Disconnected from location #{state.config.location_id}! #{inspect(connection_status)}")

    {:ok, state}
  end

  def handle_frame({:text, "{" <> _ = json}, state) do
    state =
      json
      |> Jason.decode()
      |> handle_race_data(state)

    {:ok, state}
  end

  # Timestamp format like: "02:47:42 GMT+0000 (Coordinated Universal Time)"
  # for some reason this is broadcast about 270 times per second with the same value which does not include fractions of a second
  # this would make sense to keep clocks in tune but it doesn't include milliseconds so I'm unclear on what its for
  # When the timestamps match, ignore, when it differs, save last timestamp for calculating time delta
  def handle_frame({:text, timestamp}, %State{last_timestamp: timestamp} = state) do
    {:ok, state}
  end

  def handle_frame({:text, <<time::binary-size(8), _::binary>> = timestamp}, %State{config: %Config{location_id: location_id}} = state) do
    clock = DateTime.utc_now() |> DateTime.to_time()

    {:ok, time} = Time.from_iso8601(time)

    delta = Time.diff(clock, time, :microsecond)
    :telemetry.execute([:kart_vids, :location_listener], %{clock_delta: delta}, %{location_id: location_id})
    # Logger.debug("Clock time vs broadcast time delta (microseconds): #{delta}")

    {:ok, %{state | last_timestamp: timestamp}}
  end

  # Ignore this bizarre frame
  def handle_frame({:text, "1"}, state) do
    {:ok, state}
  end

  def handle_frame(other, state) do
    Logger.warn("Received other frame: #{inspect(other)}")
    {:ok, state}
  end

  ## Handle Race Finish
  def handle_race_data(
        {:ok, msg = %{"race" => race = %{"id" => id, "ended" => 1, "race_name" => name, "racers" => racers, "speed_level_id" => speed_level}}},
        %State{current_race: current_race, current_race_started_at: started_at, fastest_speed_level: fastest_speed_level, config: %Config{location: location}} = state
      ) do
    laps = Map.get(race, "laps", [])
    race_by = Map.get(race, "race_by")
    win_by = Map.get(race, "win_by")
    scoreboard = Map.get(msg, "scoreboard")
    speed = parse_speed_level(speed_level)
    racer_data = extract_racer_data(racers)

    scoreboard_by_kart =
      if current_race == id && scoreboard do
        scoreboard_by_kart = extract_scoreboard_data(scoreboard)
        Logger.info("Race (#{current_race}) #{name} Complete! Started at #{started_at} with #{length(racers)} racers and scoreboard was")
        Logger.info("Scoreboard: #{inspect(scoreboard_by_kart)}")

        if fastest_speed_level == @fastest_speed_level do
          persist_kart_information(scoreboard_by_kart, location)
        else
          Logger.info("Dropping race because speed level was only level #{state.fastest_speed_level} at its fastest")
        end

        persist_race_information(name, id, started_at, racer_data, laps, race_by, location)
      else
        Logger.warn("Race ended without scoreboard")

        nil
      end

    # Update for broadcast but don't keep it
    state
    |> Map.merge(%{current_race: id, race_name: name, racers: racer_data, fastest_speed_level: fastest_speed_level, speed_level: speed, scoreboard: scoreboard_by_kart, win_by: win_by})
    |> broadcast("race_completed")

    state
    |> Map.merge(%{current_race: nil, current_race_started_at: nil, race_name: nil, racers: racer_data, fastest_speed_level: fastest_speed_level, speed_level: speed, scoreboard: scoreboard_by_kart, win_by: win_by})
  end

  ## Handle Race Start/Updates

  # Race we are already tracking, where ids match
  def handle_race_data(
        {:ok, %{"race" => race = %{"id" => id, "speed_level_id" => speed_level, "ended" => 0, "race_name" => name, "racers" => racers}}},
        %State{current_race: id, fastest_speed_level: fastest_speed_level} = state
      ) do
    speed = parse_speed_level(speed_level)
    win_by = Map.get(race, "win_by")
    new_speed = min(speed, fastest_speed_level || 99)

    if new_speed != speed do
      Logger.info("Speed changed from #{speed} to #{new_speed}!")
    end

    state
    |> Map.merge(%{current_race: id, fastest_speed_level: new_speed, speed_level: speed, race_name: name, racers: extract_racer_data(racers), scoreboard: nil, win_by: win_by})
    |> broadcast("race_data")
  end

  # Race just beginning
  def handle_race_data(
        {:ok, %{"race" => race = %{"id" => id, "speed_level_id" => speed_level, "starts_at_iso" => starts_at, "ended" => 0, "race_name" => name, "racers" => racers}}},
        %State{} = state
      ) do
    speed = parse_speed_level(speed_level)
    win_by = Map.get(race, "win_by")
    Logger.info("Race: #{name} started at #{starts_at} is running at speed #{speed_level} with #{length(racers)} racers")

    state
    |> Map.merge(%{current_race: id, current_race_started_at: DateTime.utc_now(), race_name: name, fastest_speed_level: speed, speed_level: speed, racers: extract_racer_data(racers), scoreboard: nil, win_by: win_by})
    |> broadcast("race_data")
  end

  # JSON was parsable but we didn't match anything above
  def handle_race_data({:ok, message}, %State{} = state) do
    Logger.warn("Unknown Message Received: #{inspect(message)}")

    state
  end

  # Data was not JSON
  def handle_race_data({:error, reason}, %State{} = state) do
    Logger.error("Unable to decode JSON: #{inspect(reason)}")

    state
  end

  defp parse_speed_level(speed_level) do
    {speed, ""} = Integer.parse(speed_level)
    speed
  end

  # Not supposed to receive any messages, so log them if we get them
  def handle_info(msg, state) do
    Logger.error("Received unknown message where process does not handle any messages: #{inspect(msg)}")

    {:ok, state}
  end

  defp broadcast(state, event) do
    state.config.location_id
    |> topic_name()
    |> KartVidsWeb.Endpoint.broadcast(event, state)

    state
  end

  defp topic_name(location_id) do
    "race_location:#{location_id}"
  end

  def persist_kart_information(kart_performance, %Location{id: location_id} = location) when is_map(kart_performance) do
    for {kart_num, performance} <- kart_performance, !is_nil(kart_num) do
      {kart_num, ""} = Integer.parse(kart_num)
      kart = Races.find_kart_by_location_and_number(location_id, kart_num)

      cond do
        kart && performance[:lap_time] > @min_lap_time && performance[:lap_time] < @max_lap_time ->
          Races.update_kart(
            kart,
            %{
              average_fastest_lap_time: (kart.average_fastest_lap_time * kart.number_of_races + performance[:lap_time]) / (kart.number_of_races + 1),
              average_rpms: div(kart.average_rpms * kart.number_of_races + performance[:rpm], kart.number_of_races + 1),
              fastest_lap_time: min(kart.fastest_lap_time, performance[:lap_time]),
              kart_num: kart_num,
              number_of_races: kart.number_of_races + 1,
              type: Kart.kart_type(kart_num, location)
            }
          )

        !kart && performance[:lap_time] > @min_lap_time && performance[:lap_time] < @max_lap_time ->
          Races.create_kart(%{
            average_fastest_lap_time: performance[:lap_time],
            average_rpms: performance[:rpm],
            fastest_lap_time: performance[:lap_time],
            kart_num: kart_num,
            number_of_races: 1,
            location_id: location_id,
            type: Kart.kart_type(kart_num, location)
          })

        true ->
          Logger.info("Kart #{kart_num} was excluded because performance data was out of bounds: #{inspect(performance)}")
      end
    end
  end

  # Do nothing if there are no laps
  def persist_race_information(_name, _id, _started_at, _racers, [], _race_by, _location), do: nil

  def persist_race_information(name, id, started_at, racers, laps, race_by, %Location{id: location_id}) do
    Races.transaction(fn ->
      {:ok, race} =
        Races.create_race(%{
          name: name,
          location_id: location_id,
          external_race_id: id,
          started_at: started_at,
          ended_at: DateTime.utc_now(),
          league?: Race.is_league_race?(name)
        })

      if race_by != "laps" && race_by != "minutes" do
        Logger.warn("Unexpected race by: #{race_by}")
      end

      for {racer_kart_num, racer} <- racers, !is_nil(racer_kart_num) do
        racer_laps = Enum.filter(laps, fn %{"kart_number" => kart_num} -> kart_num == racer_kart_num end)

        Races.create_racer(%{
          average_lap: racer.average_lap,
          fastest_lap: racer.fastest_lap,
          kart_num: racer.kart_num,
          nickname: racer.nickname,
          photo: racer.photo,
          position: racer.position,
          race_id: race.id,
          laps: racer_laps
        })
      end
    end)
  end

  def extract_scoreboard_data(results) when is_list(results) do
    Enum.reduce(results, %{}, fn
      %{"fastest_lap_time" => lap_time, "kart_num" => kart_num, "rpm" => rpm, "position" => position}, karts when not is_nil(kart_num) ->
        {position, ""} = Integer.parse(position)
        {rpm, ""} = Integer.parse(rpm)
        {lap_time, ""} = Float.parse(lap_time)
        Map.put(karts, kart_num, %{lap_time: lap_time, rpm: rpm, position: position})

      _, karts ->
        karts
    end)
  end

  @typep racer :: %{String.t() => String.t(), String.t() => list(lap()), String.t() => String.t()}
  @spec extract_racer_data(%{String.t() => Racer.t()}, list(racer())) :: %{String.t() => racer()}
  def extract_racer_data(by_kart \\ %{}, racers)

  def extract_racer_data(by_kart, []) do
    by_kart
    |> Enum.to_list()
    |> Enum.sort_by(fn {_kart_num, %Racer{fastest_lap: fastest_lap}} ->
      fastest_lap
    end)
    |> Stream.with_index()
    |> Stream.map(fn {{kart_num, racer}, index} ->
      racer = %{racer | position: index + 1}
      {kart_num, racer}
    end)
    |> Enum.into(%{})
  end

  def extract_racer_data(by_kart, [%{"kart_number" => kart_num, "laps" => laps, "nickname" => nickname, "photo_url" => photo} | racers]) do
    {fastest_lap, average_lap, last_lap} = analyze_laps(laps)

    by_kart
    |> add_racer(kart_num, nickname, photo, fastest_lap, average_lap, last_lap, laps)
    |> extract_racer_data(racers)
  end

  # No lap data, use nil for all lap related fields
  def extract_racer_data(by_kart, [%{"kart_number" => kart_num, "nickname" => nickname, "photo_url" => photo} | racers]) do
    by_kart
    |> add_racer(kart_num, nickname, photo, nil, nil, nil, [])
    |> extract_racer_data(racers)
  end

  # Sometime kart number is nil, not really sure what to do about that so just don't crash
  defp add_racer(by_kart, nil, nickname, photo, fastest_lap, average_lap, last_lap, laps) do
    Logger.warn("Unable to add racer with null kart number: #{inspect(%{nickname: nickname, photo: photo, fastest_lap: fastest_lap, average_lap: average_lap, last_lap: last_lap, laps: laps})}")
    by_kart
  end

  defp add_racer(by_kart, kart_num, nickname, photo, fastest_lap, average_lap, last_lap, laps) do
    {kart_number, ""} = Integer.parse(kart_num)

    by_kart
    |> Map.put(kart_num, %Racer{nickname: nickname, kart_num: kart_number, photo: photo, fastest_lap: fastest_lap, average_lap: average_lap, last_lap: last_lap, laps: laps})
  end

  @typep lap :: %{String.t() => float(), String.t() => String.t()}
  @typep analysis :: {float() | nil, float() | nil, float() | nil}
  @spec analyze_laps(list(lap()), analysis()) :: analysis()
  def analyze_laps(laps, results \\ {nil, nil, nil})
  def analyze_laps([], results), do: results

  def analyze_laps([lap | laps], results) do
    {fastest_lap, average_lap, last_lap} = analyze_lap(lap, results)
    analyze_laps(laps, {fastest_lap, average_lap, last_lap})
  end

  @spec analyze_lap(lap(), analysis()) :: analysis()
  # Discard this lap because it just marks the amb time start
  def analyze_lap(%{"lap_time" => 0, "lap_number" => "0"}, _), do: {nil, nil, nil}
  def analyze_lap(%{"lap_time" => 0.0, "lap_number" => "0"}, _), do: {nil, nil, nil}

  def analyze_lap(%{"lap_time" => lap_time, "lap_number" => lap}, {fastest_lap, average_lap, _last_lap}) when fastest_lap > lap_time do
    {lap, ""} = Integer.parse(lap)
    # First lap
    if average_lap == nil do
      {lap_time, lap_time, lap_time}
    else
      {lap_time, average_lap_time(average_lap, lap, lap_time), lap_time}
    end
  end

  def analyze_lap(%{"lap_time" => lap_time, "lap_number" => lap}, {fastest_lap, average_lap, _last_lap}) when fastest_lap <= lap_time do
    {lap, ""} = Integer.parse(lap)
    # Since `nil > 0.0 == true`, no need to check for nil here since fastest_lap cannot be less than lap_time
    {fastest_lap, average_lap_time(average_lap, lap, lap_time), lap_time}
  end

  @spec average_lap_time(float(), pos_integer(), float()) :: float()
  defp average_lap_time(average_lap, lap, lap_time) do
    (average_lap * (lap + 1) + lap_time) / (lap + 2)
  end

  def fastest_speed_level(), do: @fastest_speed_level
end

# %{
#   "race" => %{
#     "duration" => "8",
#     "ended" => 1,
#     "heat_status_id" => "3",
#     "heat_type_id" => "197",
#     "id" => "167743",
#     "laps" => [
#       %{
#         "amb_time" => 44_566_778.556,
#         "id" => "7629509",
#         "kart_number" => "10",
#         "lap_number" => "0",
#         "lap_time" => 0,
#         "racer_id" => "11196436"
#       },
#       %{
#         "amb_time" => 44_566_782.397,
#         "id" => "7629510",
#         "kart_number" => "3",
#         "lap_number" => "0",
#         "lap_time" => 0,
#         "racer_id" => "11240382"
#       },
#       %{
#         "amb_time" => 44_566_787.95,
#         "id" => "7629511",
#         "kart_number" => "1",
#         "lap_number" => "0",
#         "lap_time" => 0,
#         "racer_id" => "11240365"
#       },
#       %{
#         "amb_time" => 44_566_792.489,
#         "id" => "7629512",
#         "kart_number" => "16",
#         "lap_number" => "0",
#         "lap_time" => 0,
#         "racer_id" => "11240367"
#       },
#       %{
#         "amb_time" => 44_566_795.708,
#         "id" => "7629513",
#         "kart_number" => "20",
#         "lap_number" => "0",
#         "lap_time" => 0,
#         "racer_id" => "11240366"
#       },
#       %{
#         "amb_time" => 44_566_798.129,
#         "id" => "7629514",
#         "kart_number" => "11",
#         "lap_number" => "0",
#         "lap_time" => 0,
#         "racer_id" => "11240370"
#       },
#       %{
#         "amb_time" => 44_566_799.869,
#         "id" => "7629515",
#         "kart_number" => "14",
#         "lap_number" => "0",
#         "lap_time" => 0,
#         "racer_id" => "11240371"
#       },
#       %{
#         "amb_time" => 44_566_821.664,
#         "id" => "7629516",
#         "kart_number" => "10",
#         "lap_number" => "1",
#         "lap_time" => 43.108,
#         "racer_id" => "11196436"
#       },
#       %{
#         "amb_time" => 44_566_841.089,
#         "id" => "7629518",
#         "kart_number" => "20",
#         "lap_number" => "1",
#         "lap_time" => 45.381,
#         "racer_id" => "11240366"
#       },
#       %{
#         "amb_time" => 44_566_828.528,
#         "id" => "7629517",
#         "kart_number" => "3",
#         "lap_number" => "1",
#         "lap_time" => 46.131,
#         "racer_id" => "11240382"
#       },
#       %{
#         "amb_time" => 44_566_847.617,
#         "id" => "7629521",
#         "kart_number" => "14",
#         "lap_number" => "1",
#         "lap_time" => 47.748,
#         "racer_id" => "11240371"
#       },
#       %{
#         "amb_time" => 44_566_846.542,
#         "id" => "7629520",
#         "kart_number" => "11",
#         "lap_number" => "1",
#         "lap_time" => 48.413,
#         "racer_id" => "11240370"
#       },
#       %{
#         "amb_time" => 44_566_841.261,
#         "id" => "7629519",
#         "kart_number" => "1",
#         "lap_number" => "1",
#         "lap_time" => 53.311,
#         "racer_id" => "11240365"
#       },
#       %{
#         "amb_time" => 44_566_847.597,
#         "id" => "7629522",
#         "kart_number" => "16",
#         "lap_number" => "1",
#         "lap_time" => 55.108,
#         "racer_id" => "11240367"
#       },
#       %{
#         "amb_time" => 44_566_865.681,
#         "id" => "7629525",
#         "kart_number" => "20",
#         "lap_number" => "2",
#         "lap_time" => 24.592,
#         "racer_id" => "11240366"
#       },
#       %{
#         "amb_time" => 44_566_853.85,
#         "id" => "7629524",
#         "kart_number" => "3",
#         "lap_number" => "2",
#         "lap_time" => 25.322,
#         "racer_id" => "11240382"
#       },
#       %{
#         "amb_time" => 44_566_873.567,
#         "id" => "7629528",
#         "kart_number" => "14",
#         "lap_number" => "2",
#         "lap_time" => 25.95,
#         "racer_id" => "11240371"
#       },
#       %{
#         "amb_time" => 44_566_872.997,
#         "id" => "7629527",
#         "kart_number" => "11",
#         "lap_number" => "2",
#         "lap_time" => 26.455,
#         "racer_id" => "11240370"
#       },
#       %{
#         "amb_time" => 44_566_848.669,
#         "id" => "7629523",
#         "kart_number" => "10",
#         "lap_number" => "2",
#         "lap_time" => 27.005,
#         "racer_id" => "11196436"
#       },
#       %{
#         "amb_time" => 44_566_871.009,
#         "id" => "7629526",
#         "kart_number" => "1",
#         "lap_number" => "2",
#         "lap_time" => 29.748,
#         "racer_id" => "11240365"
#       },
#       %{
#         "amb_time" => 44_566_885.853,
#         "id" => "7629531",
#         "kart_number" => "16",
#         "lap_number" => "2",
#         "lap_time" => 38.256,
#         "racer_id" => "11240367"
#       },
#       %{
#         "amb_time" => 44_566_890.285,
#         "id" => "7629532",
#         "kart_number" => "20",
#         "lap_number" => "3",
#         "lap_time" => 24.604,
#         "racer_id" => "11240366"
#       },
#       %{
#         "amb_time" => 44_566_898.912,
#         "id" => "7629533",
#         "kart_number" => "11",
#         "lap_number" => "3",
#         "lap_time" => 25.915,
#         "racer_id" => "11240370"
#       },
#       %{
#         "amb_time" => 44_566_880.066,
#         "id" => "7629530",
#         "kart_number" => "3",
#         "lap_number" => "3",
#         "lap_time" => 26.216,
#         "racer_id" => "11240382"
#       },
#       %{
#         "amb_time" => 44_566_901.917,
#         "id" => "7629535",
#         "kart_number" => "14",
#         "lap_number" => "3",
#         "lap_time" => 28.35,
#         "racer_id" => "11240371"
#       },
#       %{
#         "amb_time" => 44_566_901.666,
#         "id" => "7629534",
#         "kart_number" => "1",
#         "lap_number" => "3",
#         "lap_time" => 30.657,
#         "racer_id" => "11240365"
#       },
#       %{
#         "amb_time" => 44_566_879.328,
#         "id" => "7629529",
#         "kart_number" => "10",
#         "lap_number" => "3",
#         "lap_time" => 30.659,
#         "racer_id" => "11196436"
#       },
#       %{
#         "amb_time" => 44_566_925.55,
#         "id" => "7629539",
#         "kart_number" => "16",
#         "lap_number" => "3",
#         "lap_time" => 39.697,
#         "racer_id" => "11240367"
#       },
#       %{
#         "amb_time" => 44_566_903.59,
#         "id" => "7629536",
#         "kart_number" => "10",
#         "lap_number" => "4",
#         "lap_time" => 24.262,
#         "racer_id" => "11196436"
#       },
#       %{
#         "amb_time" => 44_566_904.528,
#         "id" => "7629537",
#         "kart_number" => "3",
#         "lap_number" => "4",
#         "lap_time" => 24.462,
#         "racer_id" => "11240382"
#       },
#       %{
#         "amb_time" => 44_566_914.96,
#         "id" => "7629538",
#         "kart_number" => "20",
#         "lap_number" => "4",
#         "lap_time" => 24.675,
#         "racer_id" => "11240366"
#       },
#       %{
#         "amb_time" => 44_566_927.266,
#         "id" => "7629541",
#         "kart_number" => "14",
#         "lap_number" => "4",
#         "lap_time" => 25.349,
#         "racer_id" => "11240371"
#       },
#       %{
#         "amb_time" => 44_566_925.822,
#         "id" => "7629540",
#         "kart_number" => "11",
#         "lap_number" => "4",
#         "lap_time" => 26.91,
#         "racer_id" => "11240370"
#       },
#       %{
#         "amb_time" => 44_566_928.692,
#         "id" => "7629542",
#         "kart_number" => "1",
#         "lap_number" => "4",
#         "lap_time" => 27.026,
#         "racer_id" => "11240365"
#       },
#       %{
#         "amb_time" => 44_566_963.766,
#         "id" => "7629551",
#         "kart_number" => "16",
#         "lap_number" => "4",
#         "lap_time" => 38.216,
#         "racer_id" => "11240367"
#       },
#       %{
#         "amb_time" => 44_566_939.535,
#         "id" => "7629545",
#         "kart_number" => "20",
#         "lap_number" => "5",
#         "lap_time" => 24.575,
#         ...
#       },
#       %{
#         "amb_time" => 44_566_929.761,
#         "id" => "7629544",
#         "kart_number" => "3",
#         "lap_number" => "5",
#         ...
#       },
#       %{
#         "amb_time" => 44_566_929.317,
#         "id" => "7629543",
#         "kart_number" => "10",
#         ...
#       },
#       %{"amb_time" => 44_566_953.348, "id" => "7629547", ...},
#       %{"amb_time" => 44_566_954.818, ...},
#       %{...},
#       ...
#     ],
#     "race_by" => "laps",
#     "race_name" => "PUBLIC Briq Adult Weekends",
#     "race_number" => "143",
#     "racers" => [
#       %{
#         "finish_position" => "2",
#         "first_name" => "Dylan",
#         "group_id" => 0,
#         "id" => "11196436",
#         "is_first_time" => "0",
#         "kart_number" => "10",
#         "laps" => [
#           %{
#             "amb_time" => 44_566_778.556,
#             "id" => "7629509",
#             "kart_number" => "10",
#             "lap_number" => "0",
#             "lap_time" => 0,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_566_821.664,
#             "id" => "7629516",
#             "kart_number" => "10",
#             "lap_number" => "1",
#             "lap_time" => 43.108,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_566_848.669,
#             "id" => "7629523",
#             "kart_number" => "10",
#             "lap_number" => "2",
#             "lap_time" => 27.005,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_566_879.328,
#             "id" => "7629529",
#             "kart_number" => "10",
#             "lap_number" => "3",
#             "lap_time" => 30.659,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_566_903.59,
#             "id" => "7629536",
#             "kart_number" => "10",
#             "lap_number" => "4",
#             "lap_time" => 24.262,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_566_929.317,
#             "id" => "7629543",
#             "kart_number" => "10",
#             "lap_number" => "5",
#             "lap_time" => 25.727,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_566_957.332,
#             "id" => "7629549",
#             "kart_number" => "10",
#             "lap_number" => "6",
#             "lap_time" => 28.015,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_566_981.492,
#             "id" => "7629556",
#             "kart_number" => "10",
#             "lap_number" => "7",
#             "lap_time" => 24.16,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_567_009.235,
#             "id" => "7629564",
#             "kart_number" => "10",
#             "lap_number" => "8",
#             "lap_time" => 27.743,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_567_037.416,
#             "id" => "7629570",
#             "kart_number" => "10",
#             "lap_number" => "9",
#             "lap_time" => 28.181,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_567_063.729,
#             "id" => "7629576",
#             "kart_number" => "10",
#             "lap_number" => "10",
#             "lap_time" => 26.313,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_567_090.286,
#             "id" => "7629584",
#             "kart_number" => "10",
#             "lap_number" => "11",
#             "lap_time" => 26.557,
#             "racer_id" => "11196436"
#           },
#           %{
#             "amb_time" => 44_567_115.051,
#             "id" => "7629590",
#             "kart_number" => "10",
#             "lap_number" => "12",
#             "lap_time" => 24.765,
#             "racer_id" => "11196436"
#           }
#         ],
#         "last_name" => "Steiner",
#         "nickname" => "Poop",
#         "photo_url" => "https://aisdulles.clubspeedtiming.com/CustomerPictures/11196436.jpg",
#         "ranking_by_rpm" => 0,
#         "rpm" => "1200",
#         "rpm_change" => "45",
#         "start_position" => "1",
#         "total_customers" => 0,
#         "total_races" => "8",
#         "total_visits" => "3"
#       },
#       %{
#         "finish_position" => "1",
#         "first_name" => "Griffin",
#         "group_id" => 0,
#         "id" => "11240382",
#         "is_first_time" => "0",
#         "kart_number" => "3",
#         "laps" => [
#           %{
#             "amb_time" => 44_566_782.397,
#             "id" => "7629510",
#             "kart_number" => "3",
#             "lap_number" => "0",
#             "lap_time" => 0,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_566_828.528,
#             "id" => "7629517",
#             "kart_number" => "3",
#             "lap_number" => "1",
#             "lap_time" => 46.131,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_566_853.85,
#             "id" => "7629524",
#             "kart_number" => "3",
#             "lap_number" => "2",
#             "lap_time" => 25.322,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_566_880.066,
#             "id" => "7629530",
#             "kart_number" => "3",
#             "lap_number" => "3",
#             "lap_time" => 26.216,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_566_904.528,
#             "id" => "7629537",
#             "kart_number" => "3",
#             "lap_number" => "4",
#             "lap_time" => 24.462,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_566_929.761,
#             "id" => "7629544",
#             "kart_number" => "3",
#             "lap_number" => "5",
#             "lap_time" => 25.233,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_566_958.01,
#             "id" => "7629550",
#             "kart_number" => "3",
#             "lap_number" => "6",
#             "lap_time" => 28.249,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_566_981.855,
#             "id" => "7629557",
#             "kart_number" => "3",
#             "lap_number" => "7",
#             "lap_time" => 23.845,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_567_008.412,
#             "id" => "7629563",
#             "kart_number" => "3",
#             "lap_number" => "8",
#             "lap_time" => 26.557,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_567_034.756,
#             "id" => "7629568",
#             "kart_number" => "3",
#             "lap_number" => "9",
#             "lap_time" => 26.344,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_567_060.271,
#             "id" => "7629575",
#             "kart_number" => "3",
#             "lap_number" => "10",
#             "lap_time" => 25.515,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_567_085.899,
#             "id" => "7629582",
#             "kart_number" => "3",
#             "lap_number" => "11",
#             "lap_time" => 25.628,
#             "racer_id" => "11240382"
#           },
#           %{
#             "amb_time" => 44_567_112.992,
#             "id" => "7629588",
#             "kart_number" => "3",
#             "lap_number" => "12",
#             "lap_time" => 27.093,
#             "racer_id" => "11240382"
#           }
#         ],
#         "last_name" => "Clear",
#         "nickname" => "Griffin",
#         "photo_url" => "https://aisdulles.clubspeedtiming.com/CustomerPictures/11240382.jpg",
#         "ranking_by_rpm" => 0,
#         "rpm" => "1280",
#         "rpm_change" => "60",
#         "start_position" => "2",
#         "total_customers" => 0,
#         "total_races" => "3",
#         "total_visits" => "1"
#       },
#       %{
#         "finish_position" => "5",
#         "first_name" => "Akilah",
#         "group_id" => 0,
#         "id" => "11240365",
#         "is_first_time" => "1",
#         "kart_number" => "1",
#         "laps" => [
#           %{
#             "amb_time" => 44_566_787.95,
#             "id" => "7629511",
#             "kart_number" => "1",
#             "lap_number" => "0",
#             "lap_time" => 0,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_566_841.261,
#             "id" => "7629519",
#             "kart_number" => "1",
#             "lap_number" => "1",
#             "lap_time" => 53.311,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_566_871.009,
#             "id" => "7629526",
#             "kart_number" => "1",
#             "lap_number" => "2",
#             "lap_time" => 29.748,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_566_901.666,
#             "id" => "7629534",
#             "kart_number" => "1",
#             "lap_number" => "3",
#             "lap_time" => 30.657,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_566_928.692,
#             "id" => "7629542",
#             "kart_number" => "1",
#             "lap_number" => "4",
#             "lap_time" => 27.026,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_566_954.818,
#             "id" => "7629548",
#             "kart_number" => "1",
#             "lap_number" => "5",
#             "lap_time" => 26.126,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_566_981.073,
#             "id" => "7629555",
#             "kart_number" => "1",
#             "lap_number" => "6",
#             "lap_time" => 26.255,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_567_007.717,
#             "id" => "7629562",
#             "kart_number" => "1",
#             "lap_number" => "7",
#             "lap_time" => 26.644,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_567_034.175,
#             "id" => "7629567",
#             "kart_number" => "1",
#             "lap_number" => "8",
#             "lap_time" => 26.458,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_567_059.692,
#             "id" => "7629574",
#             "kart_number" => "1",
#             "lap_number" => "9",
#             "lap_time" => 25.517,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_567_085.477,
#             "id" => "7629581",
#             "kart_number" => "1",
#             "lap_number" => "10",
#             "lap_time" => 25.785,
#             "racer_id" => "11240365"
#           },
#           %{
#             "amb_time" => 44_567_112.653,
#             "id" => "7629587",
#             "kart_number" => "1",
#             "lap_number" => "11",
#             "lap_time" => 27.176,
#             "racer_id" => "11240365"
#           }
#         ],
#         "last_name" => "West",
#         "nickname" => "A Kil Ah",
#         "photo_url" => "https://aisdulles.clubspeedtiming.com/CustomerPictures/11240365.jpg",
#         "ranking_by_rpm" => 0,
#         "rpm" => "1200",
#         "rpm_change" => "-15",
#         "start_position" => "3",
#         "total_customers" => 0,
#         "total_races" => "1",
#         "total_visits" => "1"
#       },
#       %{
#         "finish_position" => "7",
#         "first_name" => "Pearlyne",
#         "group_id" => 0,
#         "id" => "11240367",
#         "is_first_time" => "1",
#         "kart_number" => "16",
#         "laps" => [
#           %{
#             "amb_time" => 44_566_792.489,
#             "id" => "7629512",
#             "kart_number" => "16",
#             "lap_number" => "0",
#             "lap_time" => 0,
#             "racer_id" => "11240367"
#           },
#           %{
#             "amb_time" => 44_566_847.597,
#             "id" => "7629522",
#             "kart_number" => "16",
#             "lap_number" => "1",
#             "lap_time" => 55.108,
#             "racer_id" => "11240367"
#           },
#           %{
#             "amb_time" => 44_566_885.853,
#             "id" => "7629531",
#             "kart_number" => "16",
#             "lap_number" => "2",
#             "lap_time" => 38.256,
#             "racer_id" => "11240367"
#           },
#           %{
#             "amb_time" => 44_566_925.55,
#             "id" => "7629539",
#             "kart_number" => "16",
#             "lap_number" => "3",
#             "lap_time" => 39.697,
#             "racer_id" => "11240367"
#           },
#           %{
#             "amb_time" => 44_566_963.766,
#             "id" => "7629551",
#             "kart_number" => "16",
#             "lap_number" => "4",
#             "lap_time" => 38.216,
#             "racer_id" => "11240367"
#           },
#           %{
#             "amb_time" => 44_567_003.012,
#             "id" => "7629559",
#             "kart_number" => "16",
#             "lap_number" => "5",
#             "lap_time" => 39.246,
#             "racer_id" => "11240367"
#           },
#           %{
#             "amb_time" => 44_567_045.874,
#             "id" => "7629572",
#             "kart_number" => "16",
#             "lap_number" => "6",
#             "lap_time" => 42.862,
#             "racer_id" => "11240367"
#           },
#           %{
#             "amb_time" => 44_567_082.503,
#             "id" => "7629579",
#             "kart_number" => "16",
#             "lap_number" => "7",
#             "lap_time" => 36.629,
#             "racer_id" => "11240367"
#           },
#           %{
#             "amb_time" => 44_567_123.918,
#             "id" => "7629591",
#             "kart_number" => "16",
#             "lap_number" => "8",
#             "lap_time" => 41.415,
#             "racer_id" => "11240367"
#           }
#         ],
#         "last_name" => "West",
#         "nickname" => "Pearl",
#         "photo_url" => "https://aisdulles.clubspeedtiming.com/CustomerPictures/11240367.jpg",
#         "ranking_by_rpm" => 0,
#         "rpm" => "1200",
#         "rpm_change" => "-53",
#         "start_position" => "4",
#         "total_customers" => 0,
#         "total_races" => "1",
#         "total_visits" => "1"
#       },
#       %{
#         "finish_position" => "3",
#         "first_name" => "Tony",
#         "group_id" => 0,
#         "id" => "11240366",
#         "is_first_time" => "0",
#         "kart_number" => "20",
#         "laps" => [
#           %{
#             "amb_time" => 44_566_795.708,
#             "id" => "7629513",
#             "kart_number" => "20",
#             "lap_number" => "0",
#             "lap_time" => 0,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_566_841.089,
#             "id" => "7629518",
#             "kart_number" => "20",
#             "lap_number" => "1",
#             "lap_time" => 45.381,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_566_865.681,
#             "id" => "7629525",
#             "kart_number" => "20",
#             "lap_number" => "2",
#             "lap_time" => 24.592,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_566_890.285,
#             "id" => "7629532",
#             "kart_number" => "20",
#             "lap_number" => "3",
#             "lap_time" => 24.604,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_566_914.96,
#             "id" => "7629538",
#             "kart_number" => "20",
#             "lap_number" => "4",
#             "lap_time" => 24.675,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_566_939.535,
#             "id" => "7629545",
#             "kart_number" => "20",
#             "lap_number" => "5",
#             "lap_time" => 24.575,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_566_964.128,
#             "id" => "7629552",
#             "kart_number" => "20",
#             "lap_number" => "6",
#             "lap_time" => 24.593,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_566_989.364,
#             "id" => "7629558",
#             "kart_number" => "20",
#             "lap_number" => "7",
#             "lap_time" => 25.236,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_567_013.89,
#             "id" => "7629565",
#             "kart_number" => "20",
#             "lap_number" => "8",
#             "lap_time" => 24.526,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_567_039.219,
#             "id" => "7629571",
#             "kart_number" => "20",
#             "lap_number" => "9",
#             "lap_time" => 25.329,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_567_064.089,
#             "id" => "7629577",
#             "kart_number" => "20",
#             "lap_number" => "10",
#             "lap_time" => 24.87,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_567_088.847,
#             "id" => "7629583",
#             "kart_number" => "20",
#             "lap_number" => "11",
#             "lap_time" => 24.758,
#             "racer_id" => "11240366"
#           },
#           %{
#             "amb_time" => 44_567_114.111,
#             "id" => "7629589",
#             "kart_number" => "20",
#             "lap_number" => "12",
#             "lap_time" => 25.264,
#             "racer_id" => "11240366"
#           }
#         ],
#         "last_name" => "West",
#         "nickname" => "T Dubb",
#         "photo_url" => "https://aisdulles.clubspeedtiming.com/CustomerPictures/11240366.jpg",
#         "ranking_by_rpm" => 0,
#         "rpm" => "1307",
#         "rpm_change" => "17",
#         "start_position" => "6",
#         "total_customers" => 0,
#         "total_races" => "3",
#         "total_visits" => "1"
#       },
#       %{
#         "finish_position" => "6",
#         "first_name" => "Sophia",
#         "group_id" => 0,
#         "id" => "11240370",
#         "is_first_time" => "0",
#         "kart_number" => "11",
#         "laps" => [
#           %{
#             "amb_time" => 44_566_798.129,
#             "id" => "7629514",
#             "kart_number" => "11",
#             "lap_number" => "0",
#             "lap_time" => 0,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_566_846.542,
#             "id" => "7629520",
#             "kart_number" => "11",
#             "lap_number" => "1",
#             "lap_time" => 48.413,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_566_872.997,
#             "id" => "7629527",
#             "kart_number" => "11",
#             "lap_number" => "2",
#             "lap_time" => 26.455,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_566_898.912,
#             "id" => "7629533",
#             "kart_number" => "11",
#             "lap_number" => "3",
#             "lap_time" => 25.915,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_566_925.822,
#             "id" => "7629540",
#             "kart_number" => "11",
#             "lap_number" => "4",
#             "lap_time" => 26.91,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_566_952.369,
#             "id" => "7629546",
#             "kart_number" => "11",
#             "lap_number" => "5",
#             "lap_time" => 26.547,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_566_978.492,
#             "id" => "7629553",
#             "kart_number" => "11",
#             "lap_number" => "6",
#             "lap_time" => 26.123,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_567_004.331,
#             "id" => "7629560",
#             "kart_number" => "11",
#             "lap_number" => "7",
#             "lap_time" => 25.839,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_567_032.574,
#             "id" => "7629566",
#             "kart_number" => "11",
#             "lap_number" => "8",
#             "lap_time" => 28.243,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_567_058.143,
#             "id" => "7629573",
#             "kart_number" => "11",
#             "lap_number" => "9",
#             "lap_time" => 25.569,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_567_084.037,
#             "id" => "7629580",
#             "kart_number" => "11",
#             "lap_number" => "10",
#             "lap_time" => 25.894,
#             "racer_id" => "11240370"
#           },
#           %{
#             "amb_time" => 44_567_111.554,
#             "id" => "7629586",
#             "kart_number" => "11",
#             "lap_number" => "11",
#             "lap_time" => 27.517,
#             "racer_id" => "11240370"
#           }
#         ],
#         "last_name" => "West",
#         "nickname" => "Sophia West",
#         "photo_url" => "https://aisdulles.clubspeedtiming.com/CustomerPictures/11240370.jpg",
#         "ranking_by_rpm" => 0,
#         "rpm" => "1080",
#         "rpm_change" => "-23",
#         "start_position" => "7",
#         "total_customers" => 0,
#         "total_races" => "3",
#         "total_visits" => "1"
#       },
#       %{
#         "finish_position" => "4",
#         "first_name" => "Justin",
#         "group_id" => 0,
#         "id" => "11240371",
#         "is_first_time" => "0",
#         "kart_number" => "14",
#         "laps" => [
#           %{
#             "amb_time" => 44_566_799.869,
#             "id" => "7629515",
#             "kart_number" => "14",
#             "lap_number" => "0",
#             "lap_time" => 0,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_566_847.617,
#             "id" => "7629521",
#             "kart_number" => "14",
#             "lap_number" => "1",
#             "lap_time" => 47.748,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_566_873.567,
#             "id" => "7629528",
#             "kart_number" => "14",
#             "lap_number" => "2",
#             "lap_time" => 25.95,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_566_901.917,
#             "id" => "7629535",
#             "kart_number" => "14",
#             "lap_number" => "3",
#             "lap_time" => 28.35,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_566_927.266,
#             "id" => "7629541",
#             "kart_number" => "14",
#             "lap_number" => "4",
#             "lap_time" => 25.349,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_566_953.348,
#             "id" => "7629547",
#             "kart_number" => "14",
#             "lap_number" => "5",
#             "lap_time" => 26.082,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_566_978.817,
#             "id" => "7629554",
#             "kart_number" => "14",
#             "lap_number" => "6",
#             "lap_time" => 25.469,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_567_004.765,
#             "id" => "7629561",
#             "kart_number" => "14",
#             "lap_number" => "7",
#             "lap_time" => 25.948,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_567_036.595,
#             "id" => "7629569",
#             "kart_number" => "14",
#             "lap_number" => "8",
#             "lap_time" => 31.83,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_567_065.256,
#             "id" => "7629578",
#             "kart_number" => "14",
#             "lap_number" => "9",
#             "lap_time" => 28.661,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_567_091.114,
#             "id" => "7629585",
#             "kart_number" => "14",
#             "lap_number" => "10",
#             "lap_time" => 25.858,
#             "racer_id" => "11240371"
#           },
#           %{
#             "amb_time" => 44_567_124.721,
#             "id" => "7629592",
#             "kart_number" => "14",
#             "lap_number" => "11",
#             "lap_time" => 33.607,
#             "racer_id" => "11240371"
#           }
#         ],
#         "last_name" => "West",
#         "nickname" => "Justin West",
#         "photo_url" => "https://aisdulles.clubspeedtiming.com/CustomerPictures/11240371.jpg",
#         "ranking_by_rpm" => 0,
#         "rpm" => "1230",
#         "rpm_change" => "4",
#         "start_position" => "8",
#         "total_customers" => 0,
#         "total_races" => "3",
#         "total_visits" => "1"
#       }
#     ],
#     "speed_level" => "Speed Level 1",
#     "speed_level_id" => "1",
#     "starts_at" => "2022-11-06 16:38:00",
#     "starts_at_iso" => "2022-11-06 16:38:00.000",
#     "track" => "Track 1",
#     "track_id" => "1",
#     "win_by" => "laptime"
#   },
#   "scoreboard" => [
#     %{
#       "ambtime" => "44567112992",
#       "average_lap_time" => "27.549",
#       "fastest_lap_time" => "23.845",
#       "first_name" => "Griffin",
#       "gap" => ".000",
#       "is_first_time" => "0",
#       "kart_num" => "3",
#       "lap_num" => "12",
#       "last_lap_time" => "27.093",
#       "last_name" => "Clear",
#       "nickname" => "Griffin",
#       "position" => "1",
#       "racer_id" => "11240382",
#       "rpm" => "1340",
#       "total_races" => "3"
#     },
#     %{
#       "ambtime" => "44567115051",
#       "average_lap_time" => "28.041",
#       "fastest_lap_time" => "24.160",
#       "first_name" => "Dylan",
#       "gap" => ".315",
#       "is_first_time" => "0",
#       "kart_num" => "10",
#       "lap_num" => "12",
#       "last_lap_time" => "24.765",
#       "last_name" => "Steiner",
#       "nickname" => "Poop",
#       "position" => "2",
#       "racer_id" => "11196436",
#       "rpm" => "1245",
#       "total_races" => "8"
#     },
#     %{
#       "ambtime" => "44567114111",
#       "average_lap_time" => "26.533",
#       "fastest_lap_time" => "24.526",
#       "first_name" => "Tony",
#       "gap" => ".681",
#       "is_first_time" => "0",
#       "kart_num" => "20",
#       "lap_num" => "12",
#       "last_lap_time" => "25.264",
#       "last_name" => "West",
#       "nickname" => "T Dubb",
#       "position" => "3",
#       "racer_id" => "11240366",
#       "rpm" => "1324",
#       "total_races" => "3"
#     },
#     %{
#       "ambtime" => "44567124721",
#       "average_lap_time" => "29.532",
#       "fastest_lap_time" => "25.349",
#       "first_name" => "Justin",
#       "gap" => "1.504",
#       "is_first_time" => "0",
#       "kart_num" => "14",
#       "lap_num" => "11",
#       "last_lap_time" => "33.607",
#       "last_name" => "West",
#       "nickname" => "Justin West",
#       "position" => "4",
#       "racer_id" => "11240371",
#       "rpm" => "1234",
#       "total_races" => "3"
#     },
#     %{
#       "ambtime" => "44567112653",
#       "average_lap_time" => "29.518",
#       "fastest_lap_time" => "25.517",
#       "first_name" => "Akilah",
#       "gap" => "1.672",
#       "is_first_time" => "1",
#       "kart_num" => "1",
#       "lap_num" => "11",
#       "last_lap_time" => "27.176",
#       "last_name" => "West",
#       "nickname" => "A Kil Ah",
#       "position" => "5",
#       "racer_id" => "11240365",
#       "rpm" => "1185",
#       "total_races" => "1"
#     },
#     %{
#       "ambtime" => "44567111554",
#       "average_lap_time" => "28.493",
#       "fastest_lap_time" => "25.569",
#       "first_name" => "Sophia",
#       "gap" => "1.724",
#       "is_first_time" => "0",
#       "kart_num" => "11",
#       "lap_num" => "11",
#       "last_lap_time" => "27.517",
#       "last_name" => "West",
#       "nickname" => "Sophia West",
#       "position" => "6",
#       "racer_id" => "11240370",
#       "rpm" => "1057",
#       "total_races" => "3"
#     },
#     %{
#       "ambtime" => "44567123918",
#       "average_lap_time" => "41.428",
#       "fastest_lap_time" => "36.629",
#       "first_name" => "Pearlyne",
#       "gap" => "12.784",
#       "is_first_time" => "1",
#       "kart_num" => "16",
#       "lap_num" => "8",
#       "last_lap_time" => "41.415",
#       "last_name" => "West",
#       "nickname" => "Pearl",
#       "position" => "7",
#       "racer_id" => "11240367",
#       "rpm" => "1147",
#       "total_races" => "1"
#     }
#   ]
# }
