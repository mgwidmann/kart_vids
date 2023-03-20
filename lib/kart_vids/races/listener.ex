defmodule KartVids.Races.Listener do
  use WebSockex
  require Logger
  alias KartVids.Races
  alias KartVids.Races.Race
  alias KartVids.Races.Kart
  alias KartVids.Content.Location

  defmodule Config do
    @moduledoc false
    @type t :: %Config{
            location_id: nil | pos_integer(),
            location: Location.t(),
            reconnect_attempt: pos_integer()
          }
    defstruct location_id: nil, location: nil, reconnect_attempt: 0

    @behaviour Access

    def fetch(term, key), do: Map.fetch(term, key)

    def get_and_update(data, key, func) do
      Map.get_and_update(data, key, func)
    end

    def pop(data, key), do: Map.pop(data, key)
  end

  defmodule State do
    @moduledoc false
    @type t :: %State{
            config: Config.t(),
            current_race: nil | Stirng.t(),
            current_race_started_at: nil | String.t(),
            last_race: nil | String.t(),
            race_name: nil | String.t(),
            fastest_speed_level: nil | pos_integer(),
            speed_level: nil | pos_integer(),
            racers: list(Racer.t()),
            scoreboard: nil | map(),
            last_timestamp: nil | String.t(),
            win_by: nil | String.t()
          }

    defstruct config: %Config{},
              current_race: nil,
              current_race_started_at: nil,
              last_race: nil,
              race_name: nil,
              fastest_speed_level: nil,
              speed_level: nil,
              racers: [],
              scoreboard: nil,
              last_timestamp: nil,
              win_by: nil

    @behaviour Access

    def fetch(term, key), do: Map.fetch(term, key)

    def get_and_update(data, key, func) do
      Map.get_and_update(data, key, func)
    end

    def pop(data, key), do: Map.pop(data, key)
  end

  defmodule Racer do
    @moduledoc false
    @derive {Phoenix.Param, key: :nickname}
    @type t :: %Racer{
            external_racer_id: String.t(),
            nickname: String.t(),
            photo: String.t(),
            kart_num: pos_integer(),
            fastest_lap: float(),
            average_lap: float(),
            last_lap: float(),
            position: pos_integer(),
            laps: list(map()),
            racer_profile_id: pos_integer() | nil
          }
    defstruct external_racer_id: nil,
              nickname: "",
              photo: "",
              kart_num: -1,
              fastest_lap: 999.99,
              average_lap: 999.99,
              last_lap: 999.99,
              position: 99,
              laps: [],
              racer_profile_id: nil
  end

  @fastest_speed_level 1

  @spec whereis(number | Location.t()) :: pid() | nil
  def whereis(%Location{id: id}), do: whereis(id)

  def whereis(location_id) when is_number(location_id) do
    case Registry.lookup(KartVids.Registry, {__MODULE__, location_id}) do
      [{pid, _} | _] -> pid
      [] -> nil
    end
  end

  def ping(pid) when is_pid(pid) do
    GenServer.call(pid, :ping)
  catch
    :exit, _value ->
      false
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
      location.websocket_url,
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

  defp via_tuple(location_id) do
    {:via, Registry, {KartVids.Registry, {__MODULE__, location_id}}}
  end

  defp agent_via_tuple(location_id) do
    {:via, Registry, {KartVids.Registry, {__MODULE__.State, location_id}}}
  end

  defp update_agent(location_id, state) do
    Agent.update(agent_via_tuple(location_id), fn _state -> state end)
  end

  def listener_state(location_id) do
    Agent.get(agent_via_tuple(location_id), & &1)
  end

  def handle_connect(conn, %Location{} = location) do
    handle_connect(conn, %State{
      config: %Config{location_id: location.id, location: location, reconnect_attempt: 0}
    })
  end

  def handle_connect(_conn, %State{config: %Config{location_id: id}} = state) do
    Logger.info("Connected to websocket for location #{id}!")

    Agent.start_link(fn -> state end, name: agent_via_tuple(id))

    {:ok, state}
  end

  @reconnect_timeout 1 * 10_000

  def handle_disconnect(connection_status, %State{} = state) do
    if state.config.reconnect_attempt > 10 do
      Logger.warn("Exiting due to repeated disconnect from location #{state.config.location_id}! #{inspect(connection_status)}")
      Agent.stop(agent_via_tuple(state.config.location_id))

      {:"$EXIT", "#{inspect(__MODULE__)}: Too many reconnect attempts!"}
    else
      Process.sleep(@reconnect_timeout)

      {:reconnect,
       WebSockex.Conn.new(state.config.location.websocket_url,
         name: via_tuple(state.config.location.id)
       ), put_in(state, [:config, :reconnect_attempt], state.config.reconnect_attempt + 1)}
    end
  end

  def handle_frame({:text, "{" <> _ = json}, state) do
    state =
      json
      |> Jason.decode()
      |> handle_race_data(state)

    update_agent(state.config.location_id, state)

    {:ok, state}
  end

  # Timestamp format like: "02:47:42 GMT+0000 (Coordinated Universal Time)"
  # for some reason this is broadcast about 270 times per second with the same value which does not include fractions of a second
  # this would make sense to keep clocks in tune but it doesn't include milliseconds so I'm unclear on what its for
  # When the timestamps match, ignore, when it differs, save last timestamp for calculating time delta
  def handle_frame({:text, timestamp}, %State{last_timestamp: timestamp} = state) do
    {:ok, state}
  end

  def handle_frame(
        {:text, <<time::binary-size(8), _::binary>> = timestamp},
        %State{config: %Config{location_id: location_id}} = state
      ) do
    clock = DateTime.utc_now() |> DateTime.to_time()

    {:ok, time} = Time.from_iso8601(time)

    delta = Time.diff(clock, time, :microsecond)

    :telemetry.execute([:kart_vids, :location_listener], %{clock_delta: delta}, %{
      location_id: location_id
    })

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

  # bestSectorTime and sectorsCount are 0
  @expected_message_keys ~w(race scoreboard bestSectorTime sectorsCount)
  # lapsOrMinutes is 0
  @expected_race_keys ~w(duration ended heat_status_id heat_type_id id laps race_by race_name race_number racers speed_level speed_level_id starts_at starts_at_iso track track_id win_by lapsOrMinutes)
  @expected_racer_keys ~w(finish_position first_name group_id id is_first_time kart_number laps last_name nickname photo_url ranking_by_rpm rpm rpm_change start_position total_customers total_races total_visits)
  @expected_lap_keys ~w(amb_time id kart_number lap_number lap_time racer_id)
  @expected_scoreboard_keys ~w(ambtime average_lap_time fastest_lap_time first_name gap is_first_time kart_num lap_num last_lap_time last_name nickname position racer_id rpm total_races)

  defmacrop log_unexpected_keys(map_or_list, name, keys) do
    set_keys = Macro.expand(keys, __ENV__) |> MapSet.new()

    quote bind_quoted: [map_or_list: map_or_list, set_keys: Macro.escape(set_keys), name: name] do
      log_map = fn map ->
        map_keys = Map.keys(map) |> MapSet.new()
        difference = MapSet.difference(map_keys, set_keys)

        unless Enum.empty?(difference) do
          Logger.warn(
            "Unexpected keys received from broadcast for the #{inspect(name)} field. Extra keys were: #{inspect(difference)}\nMap Keys: #{inspect(map_keys)}\nExpected: #{inspect(set_keys)}\nThe value of these keys were: #{inspect(Map.take(map, MapSet.to_list(difference)))}"
          )
        end
      end

      case map_or_list do
        map when is_map(map) ->
          log_map.(map)

        list when is_list(list) ->
          for item <- list do
            log_map.(item)
          end
      end
    end
  end

  ## Handle Race Finish
  def handle_race_data(
        {:ok,
         msg = %{
           "race" =>
             race = %{
               "id" => id,
               "ended" => 1,
               "race_name" => name,
               "racers" => racers,
               "speed_level_id" => speed_level
             },
           "scoreboard" => scoreboard
         }},
        %State{
          current_race: current_race,
          current_race_started_at: started_at,
          fastest_speed_level: fastest_speed_level,
          config: %Config{location: location}
        } = state
      ) do
    log_unexpected_keys(msg, "message", @expected_message_keys)
    log_unexpected_keys(race, "race", @expected_race_keys)
    log_unexpected_keys(scoreboard, "scoreboard", @expected_scoreboard_keys)
    laps = Map.get(race, "laps", [])
    log_unexpected_keys(laps, "race.laps", @expected_lap_keys)
    race_by = Map.get(race, "race_by")
    win_by = Map.get(race, "win_by")
    speed = parse_speed_level(speed_level)
    racer_data = extract_racer_data(racers)
    scoreboard_by_kart = extract_scoreboard_data(scoreboard)

    profile_id_by_kart =
      if current_race == id do
        Logger.info("Race (#{current_race}) #{name} Complete! Started at #{started_at} with #{length(racers)} racers and scoreboard was")

        Logger.info("Scoreboard: #{inspect(scoreboard_by_kart)}")

        race_info = persist_race_information(name, id, started_at, racer_data, laps, race_by, win_by, location)

        # Persist race information first so the data will be used in calculations for karts
        persist_kart_information(scoreboard_by_kart, location)

        race_info
      else
        if unquote(Mix.env()) == :prod do
          Logger.info("Race #{current_race} #{name} Complete! Started at #{started_at || "(unknown)"} with #{length(racers)} racers")
        end

        get_profile_ids_for_racer_data(racer_data)
      end

    racer_data = augment_racer_data(racer_data, profile_id_by_kart)

    # Update for broadcast but don't keep it
    state
    |> Map.merge(%{
      current_race: id,
      race_name: name,
      racers: racer_data,
      fastest_speed_level: fastest_speed_level,
      speed_level: speed,
      scoreboard: scoreboard_by_kart,
      win_by: win_by
    })
    |> broadcast("race_completed")

    state
    |> Map.merge(%{
      current_race: nil,
      last_race: id,
      current_race_started_at: nil,
      race_name: nil,
      racers: racer_data,
      fastest_speed_level: fastest_speed_level,
      speed_level: speed,
      scoreboard: scoreboard_by_kart,
      win_by: win_by
    })
  end

  ## Handle Race Start/Updates

  # Race we are already tracking, where ids match
  def handle_race_data(
        {:ok,
         msg = %{
           "race" =>
             race = %{
               "id" => id,
               "speed_level_id" => speed_level,
               "ended" => 0,
               "race_name" => name,
               "racers" => racers
             }
         }},
        %State{current_race: id, fastest_speed_level: fastest_speed_level} = state
      ) do
    log_unexpected_keys(msg, "message", @expected_message_keys)
    log_unexpected_keys(race, "race", @expected_race_keys)

    if unquote(Mix.env()) == :prod do
      Logger.info("Race #{name} (#{id}) continues with #{length(racers)} racers")
    end

    speed = parse_speed_level(speed_level)
    win_by = Map.get(race, "win_by")
    new_speed = min(speed, fastest_speed_level || 99)

    if new_speed != speed do
      Logger.info("Speed changed from #{speed} to #{new_speed}!")
    end

    state
    |> Map.merge(%{
      current_race: id,
      fastest_speed_level: new_speed,
      speed_level: speed,
      race_name: name,
      racers: extract_racer_data(racers),
      scoreboard: nil,
      win_by: win_by
    })
    |> broadcast("race_data")
  end

  # Race just beginning
  def handle_race_data(
        {:ok,
         msg = %{
           "race" =>
             race = %{
               "id" => id,
               "speed_level_id" => speed_level,
               "starts_at_iso" => starts_at,
               "ended" => 0,
               "race_name" => name,
               "racers" => racers
             }
         }},
        %State{} = state
      ) do
    log_unexpected_keys(msg, "message", @expected_message_keys)
    log_unexpected_keys(race, "race", @expected_race_keys)
    speed = parse_speed_level(speed_level)
    win_by = Map.get(race, "win_by")

    Logger.info("Race: #{name} started at #{starts_at} is running at speed #{speed_level} with #{length(racers)} racers")

    racer_data = extract_racer_data(racers)
    profile_ids_by_kart = get_profile_ids_for_racer_data(racer_data)
    racer_data = augment_racer_data(racer_data, profile_ids_by_kart)

    state
    |> Map.merge(%{
      current_race: id,
      current_race_started_at: DateTime.utc_now(),
      race_name: name,
      fastest_speed_level: speed,
      speed_level: speed,
      racers: racer_data,
      scoreboard: nil,
      win_by: win_by
    })
    |> broadcast("race_data")
  end

  # Minimum time to log warning about abrupt ending of races, anything less than 3 minutes means the racers likely didn't actually race, convert from ms to seconds
  @minimum_duration_report_warning :timer.minutes(3) |> div(1000)
  def handle_race_data(
        {:ok,
         msg = %{
           "race" => race = %{"id" => id, "ended" => 1, "duration" => duration, "racers" => racers}
         }},
        %State{} = state
      ) do
    log_unexpected_keys(msg, "message", @expected_message_keys)
    log_unexpected_keys(race, "race", @expected_race_keys)

    unless duration > @minimum_duration_report_warning do
      Logger.warning("Race ID #{id} ended abruptly without scoreboard! Duration was: #{duration} Racers count: #{length(racers)}-- Message Keys: #{inspect(Map.keys(msg))}, Race Keys: #{inspect(Map.keys(race))}")
    end

    state
  end

  # JSON was parsable but we didn't match anything above
  def handle_race_data({:ok, message}, %State{} = state) do
    log_unexpected_keys(message, "message", @expected_message_keys)
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

  # This is not actually a GenServer...
  def handle_info({:"$gen_call", caller, :ping}, state = %State{config: %Config{location_id: location_id}}) do
    Logger.info("Listener (#{location_id}) answering :ping call")
    GenServer.reply(caller, :pong)
    {:ok, state}
  end

  # Not supposed to receive any other messages, so log them if we get them
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

  def persist_kart_information(kart_performance, %Location{id: location_id} = location)
      when is_map(kart_performance) do
    for {kart_num, performance} <- kart_performance, !is_nil(kart_num), !is_nil(performance) do
      {kart_num, ""} = Integer.parse(kart_num)
      kart = Races.find_kart_by_location_and_number(location_id, kart_num)

      stats = KartVids.Karts.compute_stats_for_kart(kart, location)

      cond do
        kart ->
          Races.update_kart(:system, kart, Map.merge(stats, %{average_rpms: div(kart.average_rpms * kart.number_of_races + performance[:rpm], kart.number_of_races + 1), type: Kart.kart_type(kart_num, location)}))

        !kart && performance[:lap_time] ->
          Races.create_kart(:system, %{
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

          if performance.lap_time < stats.fastest_lap_time do
            Logger.warning("Kart #{kart_num} was excluded because performance data was too low out of bounds: #{inspect(performance)}")
          end
      end
    end
  end

  # Do nothing if there are no laps
  def persist_race_information(_name, _id, _started_at, _racers, [], _race_by, _location), do: %{}

  def persist_race_information(name, id, started_at, racers, laps, race_by, win_by, %Location{
        id: location_id
      }) do
    {:ok, race} =
      Races.create_race(:system, %{
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

    if win_by != "laptime" && win_by != "position" do
      Logger.warn("Unexpected win by: #{win_by}")
    end

    for {racer_kart_num, racer} <- racers, racer_kart_num != nil, racer.nickname != nil, racer.photo != nil, into: %{} do
      racer_laps = Stream.filter(laps, fn %{"kart_number" => kart_num} -> kart_num == racer_kart_num end) |> Enum.reject(fn %{"lap_time" => lap_time} -> lap_time < KartVids.Karts.minimum_lap_time() end)

      if Enum.empty?(racer_laps) do
        {"-1", false}
      else
        try do
          case Races.upsert_racer_profile(%{
                 nickname: racer.nickname,
                 photo: racer.photo,
                 fastest_lap_time: racer.fastest_lap,
                 fastest_lap_kart: racer.kart_num,
                 fastest_lap_race_id: race.id,
                 external_racer_id: racer.external_racer_id
               }) do
            {:ok, profile} ->
              Races.create_racer(:system, %{
                average_lap: racer.average_lap,
                fastest_lap: racer.fastest_lap,
                kart_num: racer.kart_num,
                nickname: racer.nickname,
                photo: racer.photo,
                position: racer.position,
                race_id: race.id,
                laps: racer_laps,
                racer_profile_id: profile.id,
                race_by: race_by,
                win_by: win_by,
                external_racer_id: racer.external_racer_id,
                location_id: location_id
              })

              {racer.kart_num, profile.id}

            {:error, changeset} ->
              Logger.warn("Unable to upsert profile due to validation failure for #{racer.nickname} #{racer.photo} - Lap: #{racer.fastest_lap} Kart: #{racer.kart_num} - #{inspect(changeset)}\n\nLaps:\n#{inspect(racer_laps)}")

              {racer.kart_num, nil}
          end
        rescue
          err ->
            Logger.error("Failure to upsert profile: #{racer.nickname} #{racer.photo} #{racer.fastest_lap} #{racer.kart_num} -- #{Exception.format(:error, err, __STACKTRACE__)}")

            {racer.kart_num, nil}
        end
      end
    end
    |> Enum.filter(fn {_key, v} -> v end)
  end

  def extract_scoreboard_data(results) when is_list(results) do
    Enum.reduce(results, %{}, fn
      %{
        "fastest_lap_time" => lap_time,
        "kart_num" => kart_num,
        "rpm" => rpm,
        "position" => position,
        "racer_id" => external_racer_id
      },
      karts
      when not is_nil(kart_num) ->
        with {position, ""} <- Integer.parse(position),
             {rpm, ""} <- Integer.parse(rpm),
             {lap_time, ""} <- Float.parse(lap_time) do
          Map.put(karts, kart_num, %{lap_time: lap_time, rpm: rpm, position: position, external_racer_id: external_racer_id})
        else
          err ->
            Logger.warn("Extract scoreboard parsing issue for #{lap_time}| #{kart_num} | #{rpm} | #{position} : #{inspect(err)}")
            karts
        end

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

  def extract_racer_data(by_kart, [
        racer = %{"id" => external_racer_id, "kart_number" => kart_num, "laps" => laps, "nickname" => nickname, "photo_url" => photo}
        | racers
      ]) do
    log_unexpected_keys(racer, "racers[*]", @expected_racer_keys)
    {fastest_lap, average_lap, last_lap} = analyze_laps(laps)

    by_kart
    |> add_racer(external_racer_id, kart_num, nickname, photo, fastest_lap, average_lap, last_lap, laps)
    |> extract_racer_data(racers)
  end

  # No lap data, use nil for all lap related fields
  def extract_racer_data(by_kart, [
        racer = %{"id" => external_racer_id, "kart_number" => kart_num, "nickname" => nickname, "photo_url" => photo} | racers
      ]) do
    log_unexpected_keys(racer, "racers[*]", @expected_racer_keys)

    by_kart
    |> add_racer(external_racer_id, kart_num, nickname, photo, nil, nil, nil, [])
    |> extract_racer_data(racers)
  end

  # Sometimes races are reset before they even begin, which results in nothing in these fields, so just skip it
  defp add_racer(by_kart, _external_racer_id, nil, _nickname, _photo, nil, nil, nil, []) do
    by_kart
  end

  defp add_racer(by_kart, external_racer_id, kart_num, nickname, photo, fastest_lap, average_lap, last_lap, laps) do
    {kart_number, ""} = Integer.parse(kart_num)

    by_kart
    |> Map.put(kart_num, %Racer{
      external_racer_id: external_racer_id,
      nickname: nickname,
      kart_num: kart_number,
      photo: photo,
      fastest_lap: fastest_lap,
      average_lap: average_lap,
      last_lap: last_lap,
      laps: laps
    })
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

  def analyze_lap(
        lap_msg = %{"lap_time" => lap_time, "lap_number" => lap},
        {fastest_lap, average_lap, _last_lap}
      )
      # nil > 0.0 == true, so this will trigger for nil data
      when fastest_lap > lap_time do
    log_unexpected_keys(lap_msg, "laps", @expected_lap_keys)

    {lap, ""} = Integer.parse(lap)
    # First lap
    if average_lap == nil || fastest_lap == nil do
      {lap_time, lap_time, lap_time}
    else
      {lap_time, average_lap_time(average_lap, lap, lap_time), lap_time}
    end
  end

  def analyze_lap(
        lap_msg = %{"lap_time" => lap_time, "lap_number" => lap},
        {fastest_lap, average_lap, _last_lap}
      )
      when fastest_lap <= lap_time do
    log_unexpected_keys(lap_msg, "laps", @expected_lap_keys)

    {lap, ""} = Integer.parse(lap)

    # Since `nil > 0.0 == true`, no need to check for nil here since fastest_lap cannot be less than lap_time
    {fastest_lap, average_lap_time(average_lap, lap, lap_time), lap_time}
  end

  @spec average_lap_time(float(), pos_integer(), float()) :: float()
  defp average_lap_time(average_lap, lap, lap_time) do
    (average_lap * (lap + 1) + lap_time) / (lap + 2)
  end

  def fastest_speed_level(), do: @fastest_speed_level

  def augment_racer_data(racer_data, profile_id_by_kart) do
    # Update racer data with racer_profile_id info
    racer_data
    |> Stream.map(fn {kart_num, racer} ->
      profile_id = Map.get(profile_id_by_kart, kart_num)
      racer = %{racer | racer_profile_id: profile_id}
      {kart_num, racer}
    end)
    |> Enum.into(%{})
  end

  def get_profile_ids_for_racer_data(racer_data) do
    # Look up profile info by composite keys
    profiles = racer_data |> Enum.map(fn {_kart_num, racer} -> %{nickname: racer.nickname, photo: racer.photo, id: Races.get_racer_profile_id(racer)} end)

    # For development, make sure the application doesn't spin logging queries over and over
    # Must use unquote because Mix.env() is not available once compiled as a release
    unless unquote(Mix.env()) == :prod do
      for {kart_num, racer} <- racer_data do
        unless Races.get_racer_profile_id(racer) do
          Races.upsert_racer_profile(%{
            nickname: racer.nickname,
            photo: racer.photo,
            fastest_lap_time: racer.fastest_lap,
            fastest_lap_kart: kart_num
            # fastest_lap_race_id:
          })
        end
      end
    end

    for {kart_num, racer} <- racer_data, profile <- profiles, profile != nil, profile.nickname == racer.nickname, profile.photo == racer.photo, into: %{} do
      {kart_num, profile.id}
    end
  end
end

# {
#   "bestSectorTime": 0,
#   "race": {
#     "duration": "8",
#     "ended": 1,
#     "heat_status_id": "2",
#     "heat_type_id": "214",
#     "id": "177855",
#     "laps": [
#       {
#         "amb_time": 51153114.024,
#         "id": "7936363",
#         "kart_number": "43",
#         "lap_number": "0",
#         "lap_time": 0,
#         "racer_id": "11251374"
#       },
#       {
#         "amb_time": 51153115.425,
#         "id": "7936364",
#         "kart_number": "42",
#         "lap_number": "0",
#         "lap_time": 0,
#         "racer_id": "11251015"
#       },
#       {
#         "amb_time": 51153116.969,
#         "id": "7936365",
#         "kart_number": "49",
#         "lap_number": "0",
#         "lap_time": 0,
#         "racer_id": "11251698"
#       },
#       {
#         "amb_time": 51153118.027,
#         "id": "7936366",
#         "kart_number": "55",
#         "lap_number": "0",
#         "lap_time": 0,
#         "racer_id": "11251276"
#       },
#       {
#         "amb_time": 51153119.886,
#         "id": "7936367",
#         "kart_number": "41",
#         "lap_number": "0",
#         "lap_time": 0,
#         "racer_id": "11251440"
#       },
#       {
#         "amb_time": 51153121.14,
#         "id": "7936368",
#         "kart_number": "48",
#         "lap_number": "0",
#         "lap_time": 0,
#         "racer_id": "11250930"
#       },
#       {
#         "amb_time": 51153122.765,
#         "id": "7936369",
#         "kart_number": "52",
#         "lap_number": "0",
#         "lap_time": 0,
#         "racer_id": "11251555"
#       },
#       {
#         "amb_time": 51153124.866,
#         "id": "7936370",
#         "kart_number": "50",
#         "lap_number": "0",
#         "lap_time": 0,
#         "racer_id": "11182183"
#       },
#       {
#         "amb_time": 51153126.773,
#         "id": "7936371",
#         "kart_number": "53",
#         "lap_number": "0",
#         "lap_time": 0,
#         "racer_id": "11251275"
#       },
#       {
#         "amb_time": 51153133.188,
#         "id": "7936372",
#         "kart_number": "31",
#         "lap_number": "0",
#         "lap_time": 0,
#         "racer_id": "11251025"
#       },
#       {
#         "amb_time": 51153160.185,
#         "id": "7936373",
#         "kart_number": "43",
#         "lap_number": "1",
#         "lap_time": 46.161,
#         "racer_id": "11251374"
#       },
#       {
#         "amb_time": 51153161.827,
#         "id": "7936374",
#         "kart_number": "42",
#         "lap_number": "1",
#         "lap_time": 46.402,
#         "racer_id": "11251015"
#       },
#       {
#         "amb_time": 51153169.964,
#         "id": "7936377",
#         "kart_number": "41",
#         "lap_number": "1",
#         "lap_time": 50.078,
#         "racer_id": "11251440"
#       },
#       {
#         "amb_time": 51153168.785,
#         "id": "7936375",
#         "kart_number": "55",
#         "lap_number": "1",
#         "lap_time": 50.758,
#         "racer_id": "11251276"
#       },
#       {
#         "amb_time": 51153174.074,
#         "id": "7936379",
#         "kart_number": "52",
#         "lap_number": "1",
#         "lap_time": 51.309,
#         "racer_id": "11251555"
#       },
#       {
#         "amb_time": 51153172.734,
#         "id": "7936378",
#         "kart_number": "48",
#         "lap_number": "1",
#         "lap_time": 51.594,
#         "racer_id": "11250930"
#       },
#       {
#         "amb_time": 51153176.703,
#         "id": "7936380",
#         "kart_number": "50",
#         "lap_number": "1",
#         "lap_time": 51.837,
#         "racer_id": "11182183"
#       },
#       {
#         "amb_time": 51153178.645,
#         "id": "7936381",
#         "kart_number": "53",
#         "lap_number": "1",
#         "lap_time": 51.872,
#         "racer_id": "11251275"
#       },
#       {
#         "amb_time": 51153169.05,
#         "id": "7936376",
#         "kart_number": "49",
#         "lap_number": "1",
#         "lap_time": 52.081,
#         "racer_id": "11251698"
#       },
#       {
#         "amb_time": 51153187.355,
#         "id": "7936382",
#         "kart_number": "31",
#         "lap_number": "1",
#         "lap_time": 54.167,
#         "racer_id": "11251025"
#       },
#       {
#         "amb_time": 51153211.578,
#         "id": "7936390",
#         "kart_number": "53",
#         "lap_number": "2",
#         "lap_time": 32.933,
#         "racer_id": "11251275"
#       },
#       {
#         "amb_time": 51153202.522,
#         "id": "7936385",
#         "kart_number": "55",
#         "lap_number": "2",
#         "lap_time": 33.737,
#         "racer_id": "11251276"
#       },
#       {
#         "amb_time": 51153208.051,
#         "id": "7936389",
#         "kart_number": "52",
#         "lap_number": "2",
#         "lap_time": 33.977,
#         "racer_id": "11251555"
#       },
#       {
#         "amb_time": 51153196.18,
#         "id": "7936384",
#         "kart_number": "42",
#         "lap_number": "2",
#         "lap_time": 34.353,
#         "racer_id": "11251015"
#       },
#       {
#         "amb_time": 51153207.47,
#         "id": "7936388",
#         "kart_number": "48",
#         "lap_number": "2",
#         "lap_time": 34.736,
#         "racer_id": "11250930"
#       },
#       {
#         "amb_time": 51153195.347,
#         "id": "7936383",
#         "kart_number": "43",
#         "lap_number": "2",
#         "lap_time": 35.162,
#         "racer_id": "11251374"
#       },
#       {
#         "amb_time": 51153212.467,
#         "id": "7936391",
#         "kart_number": "50",
#         "lap_number": "2",
#         "lap_time": 35.764,
#         "racer_id": "11182183"
#       },
#       {
#         "amb_time": 51153207.11,
#         "id": "7936387",
#         "kart_number": "41",
#         "lap_number": "2",
#         "lap_time": 37.146,
#         "racer_id": "11251440"
#       },
#       {
#         "amb_time": 51153206.813,
#         "id": "7936386",
#         "kart_number": "49",
#         "lap_number": "2",
#         "lap_time": 37.763,
#         "racer_id": "11251698"
#       },
#       {
#         "amb_time": 51153226.732,
#         "id": "7936394",
#         "kart_number": "31",
#         "lap_number": "2",
#         "lap_time": 39.377,
#         "racer_id": "11251025"
#       },
#       {
#         "amb_time": 51153236.408,
#         "id": "7936396",
#         "kart_number": "48",
#         "lap_number": "3",
#         "lap_time": 28.938,
#         "racer_id": "11250930"
#       },
#       {
#         "amb_time": 51153237.442,
#         "id": "7936397",
#         "kart_number": "52",
#         "lap_number": "3",
#         "lap_time": 29.391,
#         "racer_id": "11251555"
#       },
#       {
#         "amb_time": 51153224.777,
#         "id": "7936392",
#         "kart_number": "43",
#         "lap_number": "3",
#         "lap_time": 29.43,
#         "racer_id": "11251374"
#       },
#       {
#         "amb_time": 51153225.874,
#         "id": "7936393",
#         "kart_number": "42",
#         "lap_number": "3",
#         "lap_time": 29.694,
#         "racer_id": "11251015"
#       },
#       {
#         "amb_time": 51153232.526,
#         "id": "7936395",
#         "kart_number": "55",
#         "lap_number": "3",
#         "lap_time": 30.004,
#         "racer_id": "11251276"
#       },
#       {
#         "amb_time": 51153238.358,
#         "id": "7936398",
#         "kart_number": "41",
#         "lap_number": "3",
#         "lap_time": 31.248,
#         "racer_id": "11251440"
#       },
#       {
#         "amb_time": 51153244.626,
#         "id": "7936400",
#         "kart_number": "50",
#         "lap_number": "3",
#         "lap_time": 32.159,
#         "racer_id": "11182183"
#       },
#       {
#         "amb_time": 51153244.172,
#         "id": "7936399",
#         "kart_number": "53",
#         "lap_number": "3",
#         "lap_time": 32.594,
#         "racer_id": "11251275"
#       },
#       {
#         "amb_time": 51153260.625,
#         "id": "7936405",
#         "kart_number": "31",
#         "lap_number": "3",
#         "lap_time": 33.893,
#         "racer_id": "11251025"
#       },
#       {
#         "amb_time": 51153245.915,
#         "id": "7936401",
#         "kart_number": "49",
#         "lap_number": "3",
#         "lap_time": 39.102,
#         "racer_id": "11251698"
#       },
#       {
#         "amb_time": 51153260.701,
#         "id": "7936404",
#         "kart_number": "55",
#         "lap_number": "4",
#         "lap_time": 28.175,
#         "racer_id": "11251276"
#       },
#       {
#         "amb_time": 51153265.969,
#         "id": "7936406",
#         "kart_number": "52",
#         "lap_number": "4",
#         "lap_time": 28.527,
#         "racer_id": "11251555"
#       },
#       {
#         "amb_time": 51153254.653,
#         "id": "7936403",
#         "kart_number": "42",
#         "lap_number": "4",
#         "lap_time": 28.779,
#         "racer_id": "11251015"
#       },
#       {
#         "amb_time": 51153253.583,
#         "id": "7936402",
#         "kart_number": "43",
#         "lap_number": "4",
#         "lap_time": 28.806,
#         "racer_id": "11251374"
#       },
#       {
#         "amb_time": 51153322.438,
#         "id": "7936409",
#         "kart_number": "53",
#         "lap_number": "4",
#         "lap_time": 78.266,
#         "racer_id": "11251275"
#       },
#       {
#         "amb_time": 51153315.446,
#         "id": "7936407",
#         "kart_number": "48",
#         "lap_number": "4",
#         "lap_time": 79.038,
#         "racer_id": "11250930"
#       },
#       {
#         "amb_time": 51153318.398,
#         "id": "7936408",
#         "kart_number": "41",
#         "lap_number": "4",
#         "lap_time": 80.04,
#         "racer_id": "11251440"
#       },
#       {
#         "amb_time": 51153325.366,
#         "id": "7936410",
#         "kart_number": "50",
#         "lap_number": "4",
#         "lap_time": 80.74,
#         "racer_id": "11182183"
#       },
#       {
#         "amb_time": 51153326.811,
#         "id": "7936411",
#         "kart_number": "49",
#         "lap_number": "4",
#         "lap_time": 80.896,
#         "racer_id": "11251698"
#       },
#       {
#         "amb_time": 51153348.416,
#         "id": "7936415",
#         "kart_number": "31",
#         "lap_number": "4",
#         "lap_time": 87.791,
#         "racer_id": "11251025"
#       },
#       {
#         "amb_time": 51153355.065,
#         "id": "7936419",
#         "kart_number": "53",
#         "lap_number": "5",
#         "lap_time": 32.627,
#         "racer_id": "11251275"
#       },
#       {
#         "amb_time": 51153352.255,
#         "id": "7936418",
#         "kart_number": "41",
#         "lap_number": "5",
#         "lap_time": 33.857,
#         "racer_id": "11251440"
#       },
#       {
#         "amb_time": 51153360.926,
#         "id": "7936421",
#         "kart_number": "49",
#         "lap_number": "5",
#         "lap_time": 34.115,
#         "racer_id": "11251698"
#       },
#       {
#         "amb_time": 51153359.995,
#         "id": "7936420",
#         "kart_number": "50",
#         "lap_number": "5",
#         "lap_time": 34.629,
#         "racer_id": "11182183"
#       },
#       {
#         "amb_time": 51153350.402,
#         "id": "7936417",
#         "kart_number": "48",
#         "lap_number": "5",
#         "lap_time": 34.956,
#         "racer_id": "11250930"
#       },
#       {
#         "amb_time": 51153390.856,
#         "id": "7936426",
#         "kart_number": "31",
#         "lap_number": "5",
#         "lap_time": 42.44,
#         "racer_id": "11251025"
#       },
#       {
#         "amb_time": 51153330.083,
#         "id": "7936412",
#         "kart_number": "43",
#         "lap_number": "5",
#         "lap_time": 76.5,
#         "racer_id": "11251374"
#       },
#       {
#         "amb_time": 51153338.757,
#         "id": "7936414",
#         "kart_number": "55",
#         "lap_number": "5",
#         "lap_time": 78.056,
#         "racer_id": "11251276"
#       },
#       {
#         "amb_time": 51153334.318,
#         "id": "7936413",
#         "kart_number": "42",
#         "lap_number": "5",
#         "lap_time": 79.665,
#         "racer_id": "11251015"
#       },
#       {
#         "amb_time": 51153348.69,
#         "id": "7936416",
#         "kart_number": "52",
#         "lap_number": "5",
#         "lap_time": 82.721,
#         "racer_id": "11251555"
#       },
#       {
#         "amb_time": 51153378.778,
#         "id": "7936425",
#         "kart_number": "52",
#         "lap_number": "6",
#         "lap_time": 30.088,
#         "racer_id": "11251555"
#       },
#       {
#         "amb_time": 51153366.567,
#         "id": "7936423",
#         "kart_number": "42",
#         "lap_number": "6",
#         "lap_time": 32.249,
#         "racer_id": "11251015"
#       },
#       {
#         "amb_time": 51153371.599,
#         "id": "7936424",
#         "kart_number": "55",
#         "lap_number": "6",
#         "lap_time": 32.842,
#         "racer_id": "11251276"
#       },
#       {
#         "amb_time": 51153363.09,
#         "id": "7936422",
#         "kart_number": "43",
#         "lap_number": "6",
#         "lap_time": 33.007,
#         "racer_id": "11251374"
#       },
#       {
#         "amb_time": 51153393.67,
#         "id": "7936429",
#         "kart_number": "53",
#         "lap_number": "6",
#         "lap_time": 38.605,
#         "racer_id": "11251275"
#       },
#       {
#         "amb_time": 51153391.109,
#         "id": "7936427",
#         "kart_number": "48",
#         "lap_number": "6",
#         "lap_time": 40.707,
#         "racer_id": "11250930"
#       },
#       {
#         "amb_time": 51153393.102,
#         "id": "7936428",
#         "kart_number": "41",
#         "lap_number": "6",
#         "lap_time": 40.847,
#         "racer_id": "11251440"
#       },
#       {
#         "amb_time": 51153404.068,
#         "id": "7936431",
#         "kart_number": "50",
#         "lap_number": "6",
#         "lap_time": 44.073,
#         "racer_id": "11182183"
#       },
#       {
#         "amb_time": 51153409.166,
#         "id": "7936433",
#         "kart_number": "49",
#         "lap_number": "6",
#         "lap_time": 48.24,
#         "racer_id": "11251698"
#       },
#       {
#         "amb_time": 51153402.207,
#         "id": "7936430",
#         "kart_number": "42",
#         "lap_number": "7",
#         "lap_time": 35.64,
#         "racer_id": "11251015"
#       },
#       {
#         "amb_time": 51153411.559,
#         "id": "7936434",
#         "kart_number": "55",
#         "lap_number": "7",
#         "lap_time": 39.96,
#         "racer_id": "11251276"
#       },
#       {
#         "amb_time": 51153407.805,
#         "id": "7936432",
#         "kart_number": "43",
#         "lap_number": "7",
#         "lap_time": 44.715,
#         "racer_id": "11251374"
#       }
#     ],
#     "race_by": "minutes",
#     "race_name": "5 Min Junior Heat - Event",
#     "race_number": "155",
#     "racers": [
#       {
#         "finish_position": "4",
#         "first_name": "Armaan",
#         "group_id": 0,
#         "id": "11251374",
#         "is_first_time": "0",
#         "kart_number": "43",
#         "laps": [
#           {
#             "amb_time": 51153114.024,
#             "id": "7936363",
#             "kart_number": "43",
#             "lap_number": "0",
#             "lap_time": 0,
#             "racer_id": "11251374"
#           },
#           {
#             "amb_time": 51153160.185,
#             "id": "7936373",
#             "kart_number": "43",
#             "lap_number": "1",
#             "lap_time": 46.161,
#             "racer_id": "11251374"
#           },
#           {
#             "amb_time": 51153195.347,
#             "id": "7936383",
#             "kart_number": "43",
#             "lap_number": "2",
#             "lap_time": 35.162,
#             "racer_id": "11251374"
#           },
#           {
#             "amb_time": 51153224.777,
#             "id": "7936392",
#             "kart_number": "43",
#             "lap_number": "3",
#             "lap_time": 29.43,
#             "racer_id": "11251374"
#           },
#           {
#             "amb_time": 51153253.583,
#             "id": "7936402",
#             "kart_number": "43",
#             "lap_number": "4",
#             "lap_time": 28.806,
#             "racer_id": "11251374"
#           },
#           {
#             "amb_time": 51153330.083,
#             "id": "7936412",
#             "kart_number": "43",
#             "lap_number": "5",
#             "lap_time": 76.5,
#             "racer_id": "11251374"
#           },
#           {
#             "amb_time": 51153363.09,
#             "id": "7936422",
#             "kart_number": "43",
#             "lap_number": "6",
#             "lap_time": 33.007,
#             "racer_id": "11251374"
#           },
#           {
#             "amb_time": 51153407.805,
#             "id": "7936432",
#             "kart_number": "43",
#             "lap_number": "7",
#             "lap_time": 44.715,
#             "racer_id": "11251374"
#           }
#         ],
#         "last_name": "Wadhawan",
#         "nickname": "Maverick",
#         "photo_url": "https://aisdulles.clubspeedtiming.com/CustomerPictures/11251374.jpg",
#         "ranking_by_rpm": 0,
#         "rpm": "1207",
#         "rpm_change": "33",
#         "start_position": "1",
#         "total_customers": 0,
#         "total_races": "6",
#         "total_visits": "2"
#       },
#       {
#         "finish_position": "3",
#         "first_name": "Gadiel",
#         "group_id": 0,
#         "id": "11251015",
#         "is_first_time": "0",
#         "kart_number": "42",
#         "laps": [
#           {
#             "amb_time": 51153115.425,
#             "id": "7936364",
#             "kart_number": "42",
#             "lap_number": "0",
#             "lap_time": 0,
#             "racer_id": "11251015"
#           },
#           {
#             "amb_time": 51153161.827,
#             "id": "7936374",
#             "kart_number": "42",
#             "lap_number": "1",
#             "lap_time": 46.402,
#             "racer_id": "11251015"
#           },
#           {
#             "amb_time": 51153196.18,
#             "id": "7936384",
#             "kart_number": "42",
#             "lap_number": "2",
#             "lap_time": 34.353,
#             "racer_id": "11251015"
#           },
#           {
#             "amb_time": 51153225.874,
#             "id": "7936393",
#             "kart_number": "42",
#             "lap_number": "3",
#             "lap_time": 29.694,
#             "racer_id": "11251015"
#           },
#           {
#             "amb_time": 51153254.653,
#             "id": "7936403",
#             "kart_number": "42",
#             "lap_number": "4",
#             "lap_time": 28.779,
#             "racer_id": "11251015"
#           },
#           {
#             "amb_time": 51153334.318,
#             "id": "7936413",
#             "kart_number": "42",
#             "lap_number": "5",
#             "lap_time": 79.665,
#             "racer_id": "11251015"
#           },
#           {
#             "amb_time": 51153366.567,
#             "id": "7936423",
#             "kart_number": "42",
#             "lap_number": "6",
#             "lap_time": 32.249,
#             "racer_id": "11251015"
#           },
#           {
#             "amb_time": 51153402.207,
#             "id": "7936430",
#             "kart_number": "42",
#             "lap_number": "7",
#             "lap_time": 35.64,
#             "racer_id": "11251015"
#           }
#         ],
#         "last_name": "Fernandez",
#         "nickname": "Gadiel Fernandez",
#         "photo_url": "https://aisdulles.clubspeedtiming.com/CustomerPictures/11251015.jpg",
#         "ranking_by_rpm": 0,
#         "rpm": "1235",
#         "rpm_change": "52",
#         "start_position": "2",
#         "total_customers": 0,
#         "total_races": "2",
#         "total_visits": "2"
#       },
#       {
#         "finish_position": "10",
#         "first_name": "Julian",
#         "group_id": 0,
#         "id": "11251698",
#         "is_first_time": "0",
#         "kart_number": "49",
#         "laps": [
#           {
#             "amb_time": 51153116.969,
#             "id": "7936365",
#             "kart_number": "49",
#             "lap_number": "0",
#             "lap_time": 0,
#             "racer_id": "11251698"
#           },
#           {
#             "amb_time": 51153169.05,
#             "id": "7936376",
#             "kart_number": "49",
#             "lap_number": "1",
#             "lap_time": 52.081,
#             "racer_id": "11251698"
#           },
#           {
#             "amb_time": 51153206.813,
#             "id": "7936386",
#             "kart_number": "49",
#             "lap_number": "2",
#             "lap_time": 37.763,
#             "racer_id": "11251698"
#           },
#           {
#             "amb_time": 51153245.915,
#             "id": "7936401",
#             "kart_number": "49",
#             "lap_number": "3",
#             "lap_time": 39.102,
#             "racer_id": "11251698"
#           },
#           {
#             "amb_time": 51153326.811,
#             "id": "7936411",
#             "kart_number": "49",
#             "lap_number": "4",
#             "lap_time": 80.896,
#             "racer_id": "11251698"
#           },
#           {
#             "amb_time": 51153360.926,
#             "id": "7936421",
#             "kart_number": "49",
#             "lap_number": "5",
#             "lap_time": 34.115,
#             "racer_id": "11251698"
#           },
#           {
#             "amb_time": 51153409.166,
#             "id": "7936433",
#             "kart_number": "49",
#             "lap_number": "6",
#             "lap_time": 48.24,
#             "racer_id": "11251698"
#           }
#         ],
#         "last_name": "Hurt",
#         "nickname": "J-Boogie",
#         "photo_url": "https://aisdulles.clubspeedtiming.com/CustomerPictures/11251698.jpg",
#         "ranking_by_rpm": 0,
#         "rpm": "1116",
#         "rpm_change": "-71",
#         "start_position": "3",
#         "total_customers": 0,
#         "total_races": "2",
#         "total_visits": "1"
#       },
#       {
#         "finish_position": "1",
#         "first_name": "Sean",
#         "group_id": 0,
#         "id": "11251276",
#         "is_first_time": "0",
#         "kart_number": "55",
#         "laps": [
#           {
#             "amb_time": 51153118.027,
#             "id": "7936366",
#             "kart_number": "55",
#             "lap_number": "0",
#             "lap_time": 0,
#             "racer_id": "11251276"
#           },
#           {
#             "amb_time": 51153168.785,
#             "id": "7936375",
#             "kart_number": "55",
#             "lap_number": "1",
#             "lap_time": 50.758,
#             "racer_id": "11251276"
#           },
#           {
#             "amb_time": 51153202.522,
#             "id": "7936385",
#             "kart_number": "55",
#             "lap_number": "2",
#             "lap_time": 33.737,
#             "racer_id": "11251276"
#           },
#           {
#             "amb_time": 51153232.526,
#             "id": "7936395",
#             "kart_number": "55",
#             "lap_number": "3",
#             "lap_time": 30.004,
#             "racer_id": "11251276"
#           },
#           {
#             "amb_time": 51153260.701,
#             "id": "7936404",
#             "kart_number": "55",
#             "lap_number": "4",
#             "lap_time": 28.175,
#             "racer_id": "11251276"
#           },
#           {
#             "amb_time": 51153338.757,
#             "id": "7936414",
#             "kart_number": "55",
#             "lap_number": "5",
#             "lap_time": 78.056,
#             "racer_id": "11251276"
#           },
#           {
#             "amb_time": 51153371.599,
#             "id": "7936424",
#             "kart_number": "55",
#             "lap_number": "6",
#             "lap_time": 32.842,
#             "racer_id": "11251276"
#           },
#           {
#             "amb_time": 51153411.559,
#             "id": "7936434",
#             "kart_number": "55",
#             "lap_number": "7",
#             "lap_time": 39.96,
#             "racer_id": "11251276"
#           }
#         ],
#         "last_name": "Seabrooks",
#         "nickname": "Sean",
#         "photo_url": "https://aisdulles.clubspeedtiming.com/CustomerPictures/11251276.jpg",
#         "ranking_by_rpm": 0,
#         "rpm": "1156",
#         "rpm_change": "95",
#         "start_position": "4",
#         "total_customers": 0,
#         "total_races": "2",
#         "total_visits": "2"
#       },
#       {
#         "finish_position": "6",
#         "first_name": "Israel",
#         "group_id": 0,
#         "id": "11251440",
#         "is_first_time": "0",
#         "kart_number": "41",
#         "laps": [
#           {
#             "amb_time": 51153119.886,
#             "id": "7936367",
#             "kart_number": "41",
#             "lap_number": "0",
#             "lap_time": 0,
#             "racer_id": "11251440"
#           },
#           {
#             "amb_time": 51153169.964,
#             "id": "7936377",
#             "kart_number": "41",
#             "lap_number": "1",
#             "lap_time": 50.078,
#             "racer_id": "11251440"
#           },
#           {
#             "amb_time": 51153207.11,
#             "id": "7936387",
#             "kart_number": "41",
#             "lap_number": "2",
#             "lap_time": 37.146,
#             "racer_id": "11251440"
#           },
#           {
#             "amb_time": 51153238.358,
#             "id": "7936398",
#             "kart_number": "41",
#             "lap_number": "3",
#             "lap_time": 31.248,
#             "racer_id": "11251440"
#           },
#           {
#             "amb_time": 51153318.398,
#             "id": "7936408",
#             "kart_number": "41",
#             "lap_number": "4",
#             "lap_time": 80.04,
#             "racer_id": "11251440"
#           },
#           {
#             "amb_time": 51153352.255,
#             "id": "7936418",
#             "kart_number": "41",
#             "lap_number": "5",
#             "lap_time": 33.857,
#             "racer_id": "11251440"
#           },
#           {
#             "amb_time": 51153393.102,
#             "id": "7936428",
#             "kart_number": "41",
#             "lap_number": "6",
#             "lap_time": 40.847,
#             "racer_id": "11251440"
#           }
#         ],
#         "last_name": "Johnson",
#         "nickname": "Israel Johnson",
#         "photo_url": "https://aisdulles.clubspeedtiming.com/CustomerPictures/11251440.jpg",
#         "ranking_by_rpm": 0,
#         "rpm": "1255",
#         "rpm_change": "-12",
#         "start_position": "5",
#         "total_customers": 0,
#         "total_races": "2",
#         "total_visits": "1"
#       },
#       {
#         "finish_position": "5",
#         "first_name": "Dj",
#         "group_id": 0,
#         "id": "11250930",
#         "is_first_time": "0",
#         "kart_number": "48",
#         "laps": [
#           {
#             "amb_time": 51153121.14,
#             "id": "7936368",
#             "kart_number": "48",
#             "lap_number": "0",
#             "lap_time": 0,
#             "racer_id": "11250930"
#           },
#           {
#             "amb_time": 51153172.734,
#             "id": "7936378",
#             "kart_number": "48",
#             "lap_number": "1",
#             "lap_time": 51.594,
#             "racer_id": "11250930"
#           },
#           {
#             "amb_time": 51153207.47,
#             "id": "7936388",
#             "kart_number": "48",
#             "lap_number": "2",
#             "lap_time": 34.736,
#             "racer_id": "11250930"
#           },
#           {
#             "amb_time": 51153236.408,
#             "id": "7936396",
#             "kart_number": "48",
#             "lap_number": "3",
#             "lap_time": 28.938,
#             "racer_id": "11250930"
#           },
#           {
#             "amb_time": 51153315.446,
#             "id": "7936407",
#             "kart_number": "48",
#             "lap_number": "4",
#             "lap_time": 79.038,
#             "racer_id": "11250930"
#           },
#           {
#             "amb_time": 51153350.402,
#             "id": "7936417",
#             "kart_number": "48",
#             "lap_number": "5",
#             "lap_time": 34.956,
#             "racer_id": "11250930"
#           },
#           {
#             "amb_time": 51153391.109,
#             "id": "7936427",
#             "kart_number": "48",
#             "lap_number": "6",
#             "lap_time": 40.707,
#             "racer_id": "11250930"
#           }
#         ],
#         "last_name": "Smith",
#         "nickname": "D. Dawg",
#         "photo_url": "https://aisdulles.clubspeedtiming.com/CustomerPictures/11250930.jpg",
#         "ranking_by_rpm": 0,
#         "rpm": "1167",
#         "rpm_change": "17",
#         "start_position": "6",
#         "total_customers": 0,
#         "total_races": "3",
#         "total_visits": "2"
#       },
#       {
#         "finish_position": "2",
#         "first_name": "Jordan",
#         "group_id": 0,
#         "id": "11251555",
#         "is_first_time": "0",
#         "kart_number": "52",
#         "laps": [
#           {
#             "amb_time": 51153122.765,
#             "id": "7936369",
#             "kart_number": "52",
#             "lap_number": "0",
#             "lap_time": 0,
#             "racer_id": "11251555"
#           },
#           {
#             "amb_time": 51153174.074,
#             "id": "7936379",
#             "kart_number": "52",
#             "lap_number": "1",
#             "lap_time": 51.309,
#             "racer_id": "11251555"
#           },
#           {
#             "amb_time": 51153208.051,
#             "id": "7936389",
#             "kart_number": "52",
#             "lap_number": "2",
#             "lap_time": 33.977,
#             "racer_id": "11251555"
#           },
#           {
#             "amb_time": 51153237.442,
#             "id": "7936397",
#             "kart_number": "52",
#             "lap_number": "3",
#             "lap_time": 29.391,
#             "racer_id": "11251555"
#           },
#           {
#             "amb_time": 51153265.969,
#             "id": "7936406",
#             "kart_number": "52",
#             "lap_number": "4",
#             "lap_time": 28.527,
#             "racer_id": "11251555"
#           },
#           {
#             "amb_time": 51153348.69,
#             "id": "7936416",
#             "kart_number": "52",
#             "lap_number": "5",
#             "lap_time": 82.721,
#             "racer_id": "11251555"
#           },
#           {
#             "amb_time": 51153378.778,
#             "id": "7936425",
#             "kart_number": "52",
#             "lap_number": "6",
#             "lap_time": 30.088,
#             "racer_id": "11251555"
#           }
#         ],
#         "last_name": "Le",
#         "nickname": "Jordan",
#         "photo_url": "https://aisdulles.clubspeedtiming.com/CustomerPictures/11251555.jpg",
#         "ranking_by_rpm": 0,
#         "rpm": "1176",
#         "rpm_change": "75",
#         "start_position": "7",
#         "total_customers": 0,
#         "total_races": "2",
#         "total_visits": "1"
#       },
#       {
#         "finish_position": "7",
#         "first_name": "Kellen",
#         "group_id": 0,
#         "id": "11182183",
#         "is_first_time": "0",
#         "kart_number": "50",
#         "laps": [
#           {
#             "amb_time": 51153124.866,
#             "id": "7936370",
#             "kart_number": "50",
#             "lap_number": "0",
#             "lap_time": 0,
#             "racer_id": "11182183"
#           },
#           {
#             "amb_time": 51153176.703,
#             "id": "7936380",
#             "kart_number": "50",
#             "lap_number": "1",
#             "lap_time": 51.837,
#             "racer_id": "11182183"
#           },
#           {
#             "amb_time": 51153212.467,
#             "id": "7936391",
#             "kart_number": "50",
#             "lap_number": "2",
#             "lap_time": 35.764,
#             "racer_id": "11182183"
#           },
#           {
#             "amb_time": 51153244.626,
#             "id": "7936400",
#             "kart_number": "50",
#             "lap_number": "3",
#             "lap_time": 32.159,
#             "racer_id": "11182183"
#           },
#           {
#             "amb_time": 51153325.366,
#             "id": "7936410",
#             "kart_number": "50",
#             "lap_number": "4",
#             "lap_time": 80.74,
#             "racer_id": "11182183"
#           },
#           {
#             "amb_time": 51153359.995,
#             "id": "7936420",
#             "kart_number": "50",
#             "lap_number": "5",
#             "lap_time": 34.629,
#             "racer_id": "11182183"
#           },
#           {
#             "amb_time": 51153404.068,
#             "id": "7936431",
#             "kart_number": "50",
#             "lap_number": "6",
#             "lap_time": 44.073,
#             "racer_id": "11182183"
#           }
#         ],
#         "last_name": "Mccall",
#         "nickname": "Kellen McCall",
#         "photo_url": "https://aisdulles.clubspeedtiming.com/CustomerPictures/11182183.jpg",
#         "ranking_by_rpm": 0,
#         "rpm": "1220",
#         "rpm_change": "-27",
#         "start_position": "8",
#         "total_customers": 0,
#         "total_races": "3",
#         "total_visits": "2"
#       },
#       {
#         "finish_position": "8",
#         "first_name": "Porter",
#         "group_id": 0,
#         "id": "11251275",
#         "is_first_time": "0",
#         "kart_number": "53",
#         "laps": [
#           {
#             "amb_time": 51153126.773,
#             "id": "7936371",
#             "kart_number": "53",
#             "lap_number": "0",
#             "lap_time": 0,
#             "racer_id": "11251275"
#           },
#           {
#             "amb_time": 51153178.645,
#             "id": "7936381",
#             "kart_number": "53",
#             "lap_number": "1",
#             "lap_time": 51.872,
#             "racer_id": "11251275"
#           },
#           {
#             "amb_time": 51153211.578,
#             "id": "7936390",
#             "kart_number": "53",
#             "lap_number": "2",
#             "lap_time": 32.933,
#             "racer_id": "11251275"
#           },
#           {
#             "amb_time": 51153244.172,
#             "id": "7936399",
#             "kart_number": "53",
#             "lap_number": "3",
#             "lap_time": 32.594,
#             "racer_id": "11251275"
#           },
#           {
#             "amb_time": 51153322.438,
#             "id": "7936409",
#             "kart_number": "53",
#             "lap_number": "4",
#             "lap_time": 78.266,
#             "racer_id": "11251275"
#           },
#           {
#             "amb_time": 51153355.065,
#             "id": "7936419",
#             "kart_number": "53",
#             "lap_number": "5",
#             "lap_time": 32.627,
#             "racer_id": "11251275"
#           },
#           {
#             "amb_time": 51153393.67,
#             "id": "7936429",
#             "kart_number": "53",
#             "lap_number": "6",
#             "lap_time": 38.605,
#             "racer_id": "11251275"
#           }
#         ],
#         "last_name": "Kight",
#         "nickname": "Porter",
#         "photo_url": "https://aisdulles.clubspeedtiming.com/CustomerPictures/11251275.jpg",
#         "ranking_by_rpm": 0,
#         "rpm": "1275",
#         "rpm_change": "-56",
#         "start_position": "9",
#         "total_customers": 0,
#         "total_races": "2",
#         "total_visits": "2"
#       },
#       {
#         "finish_position": "9",
#         "first_name": "Alex",
#         "group_id": 0,
#         "id": "11251025",
#         "is_first_time": "0",
#         "kart_number": "31",
#         "laps": [
#           {
#             "amb_time": 51153133.188,
#             "id": "7936372",
#             "kart_number": "31",
#             "lap_number": "0",
#             "lap_time": 0,
#             "racer_id": "11251025"
#           },
#           {
#             "amb_time": 51153187.355,
#             "id": "7936382",
#             "kart_number": "31",
#             "lap_number": "1",
#             "lap_time": 54.167,
#             "racer_id": "11251025"
#           },
#           {
#             "amb_time": 51153226.732,
#             "id": "7936394",
#             "kart_number": "31",
#             "lap_number": "2",
#             "lap_time": 39.377,
#             "racer_id": "11251025"
#           },
#           {
#             "amb_time": 51153260.625,
#             "id": "7936405",
#             "kart_number": "31",
#             "lap_number": "3",
#             "lap_time": 33.893,
#             "racer_id": "11251025"
#           },
#           {
#             "amb_time": 51153348.416,
#             "id": "7936415",
#             "kart_number": "31",
#             "lap_number": "4",
#             "lap_time": 87.791,
#             "racer_id": "11251025"
#           },
#           {
#             "amb_time": 51153390.856,
#             "id": "7936426",
#             "kart_number": "31",
#             "lap_number": "5",
#             "lap_time": 42.44,
#             "racer_id": "11251025"
#           }
#         ],
#         "last_name": "Baker",
#         "nickname": "AggieB21",
#         "photo_url": "https://aisdulles.clubspeedtiming.com/CustomerPictures/11251025.jpg",
#         "ranking_by_rpm": 0,
#         "rpm": "1134",
#         "rpm_change": "-56",
#         "start_position": "10",
#         "total_customers": 0,
#         "total_races": "3",
#         "total_visits": "2"
#       }
#     ],
#     "speed_level": "Speed Level 2",
#     "speed_level_id": "2",
#     "starts_at": "2023-01-21 22:16:00",
#     "starts_at_iso": "2023-01-21 22:16:00.000",
#     "track": "Track 1",
#     "track_id": "1",
#     "win_by": "laptime"
#   },
#   "scoreboard": [
#     {
#       "ambtime": "51153411559",
#       "average_lap_time": "41.933",
#       "fastest_lap_time": "28.175",
#       "first_name": "Sean",
#       "gap": ".000",
#       "is_first_time": "0",
#       "kart_num": "55",
#       "lap_num": "7",
#       "last_lap_time": "39.960",
#       "last_name": "Seabrooks",
#       "nickname": "Sean",
#       "position": "1",
#       "racer_id": "11251276",
#       "rpm": "1251",
#       "total_races": "2"
#     },
#     {
#       "ambtime": "51153378778",
#       "average_lap_time": "42.668",
#       "fastest_lap_time": "28.527",
#       "first_name": "Jordan",
#       "gap": ".352",
#       "is_first_time": "0",
#       "kart_num": "52",
#       "lap_num": "6",
#       "last_lap_time": "30.088",
#       "last_name": "Le",
#       "nickname": "Jordan",
#       "position": "2",
#       "racer_id": "11251555",
#       "rpm": "1251",
#       "total_races": "2"
#     },
#     {
#       "ambtime": "51153402207",
#       "average_lap_time": "40.968",
#       "fastest_lap_time": "28.779",
#       "first_name": "Gadiel",
#       "gap": ".604",
#       "is_first_time": "0",
#       "kart_num": "42",
#       "lap_num": "7",
#       "last_lap_time": "35.640",
#       "last_name": "Fernandez",
#       "nickname": "Gadiel Fernandez",
#       "position": "3",
#       "racer_id": "11251015",
#       "rpm": "1287",
#       "total_races": "2"
#     },
#     {
#       "ambtime": "51153407805",
#       "average_lap_time": "41.968",
#       "fastest_lap_time": "28.806",
#       "first_name": "Armaan",
#       "gap": ".631",
#       "is_first_time": "0",
#       "kart_num": "43",
#       "lap_num": "7",
#       "last_lap_time": "44.715",
#       "last_name": "Wadhawan",
#       "nickname": "Maverick",
#       "position": "4",
#       "racer_id": "11251374",
#       "rpm": "1240",
#       "total_races": "6"
#     },
#     {
#       "ambtime": "51153391109",
#       "average_lap_time": "44.994",
#       "fastest_lap_time": "28.938",
#       "first_name": "Dj",
#       "gap": ".763",
#       "is_first_time": "0",
#       "kart_num": "48",
#       "lap_num": "6",
#       "last_lap_time": "40.707",
#       "last_name": "Smith",
#       "nickname": "D. Dawg",
#       "position": "5",
#       "racer_id": "11250930",
#       "rpm": "1184",
#       "total_races": "3"
#     },
#     {
#       "ambtime": "51153393102",
#       "average_lap_time": "45.536",
#       "fastest_lap_time": "31.248",
#       "first_name": "Israel",
#       "gap": "3.073",
#       "is_first_time": "0",
#       "kart_num": "41",
#       "lap_num": "6",
#       "last_lap_time": "40.847",
#       "last_name": "Johnson",
#       "nickname": "Israel Johnson",
#       "position": "6",
#       "racer_id": "11251440",
#       "rpm": "1243",
#       "total_races": "2"
#     },
#     {
#       "ambtime": "51153404068",
#       "average_lap_time": "46.533",
#       "fastest_lap_time": "32.159",
#       "first_name": "Kellen",
#       "gap": "3.984",
#       "is_first_time": "0",
#       "kart_num": "50",
#       "lap_num": "6",
#       "last_lap_time": "44.073",
#       "last_name": "Mccall",
#       "nickname": "Kellen McCall",
#       "position": "7",
#       "racer_id": "11182183",
#       "rpm": "1193",
#       "total_races": "3"
#     },
#     {
#       "ambtime": "51153393670",
#       "average_lap_time": "44.482",
#       "fastest_lap_time": "32.594",
#       "first_name": "Porter",
#       "gap": "4.419",
#       "is_first_time": "0",
#       "kart_num": "53",
#       "lap_num": "6",
#       "last_lap_time": "38.605",
#       "last_name": "Kight",
#       "nickname": "Porter",
#       "position": "8",
#       "racer_id": "11251275",
#       "rpm": "1219",
#       "total_races": "2"
#     },
#     {
#       "ambtime": "51153390856",
#       "average_lap_time": "51.533",
#       "fastest_lap_time": "33.893",
#       "first_name": "Alex",
#       "gap": "5.718",
#       "is_first_time": "0",
#       "kart_num": "31",
#       "lap_num": "5",
#       "last_lap_time": "42.440",
#       "last_name": "Baker",
#       "nickname": "AggieB21",
#       "position": "9",
#       "racer_id": "11251025",
#       "rpm": "1078",
#       "total_races": "3"
#     },
#     {
#       "ambtime": "51153409166",
#       "average_lap_time": "48.699",
#       "fastest_lap_time": "34.115",
#       "first_name": "Julian",
#       "gap": "5.940",
#       "is_first_time": "0",
#       "kart_num": "49",
#       "lap_num": "6",
#       "last_lap_time": "48.240",
#       "last_name": "Hurt",
#       "nickname": "J-Boogie",
#       "position": "10",
#       "racer_id": "11251698",
#       "rpm": "1045",
#       "total_races": "2"
#     }
#   ],
#   "sectorsCount": 0
# }
