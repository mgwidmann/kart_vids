defmodule KartVids.Races.Season.Analyzer do
  @moduledoc false
  use GenServer
  require Logger

  # alias KartVids.Races.League
  alias KartVids.Races
  alias KartVids.Content.Location
  alias KartVids.Races.{Season, Race, RacerProfile}
  alias KartVids.Races.Listener, as: RaceListener

  @minimum_racers 3

  def start_link(season, timeout \\ :timer.seconds(30))

  # Check that the location and season_racers relation is loaded, either no racers or one struct which is a %RacerProfile{}
  def start_link(season = %Season{location: %Location{}, season_racers: []}, timeout) do
    do_start_link(season, timeout)
  end

  def start_link(season = %Season{location: %Location{}, season_racers: [%RacerProfile{} | _]}, timeout) do
    do_start_link(season, timeout)
  end

  defp do_start_link(season, timeout) do
    GenServer.start_link(__MODULE__, {season, timeout}, name: via_tuple(season.id))
  end

  defmodule State do
    @type t :: %State{
            season: Season.t(),
            watching: Date.t(),
            watch_until: DateTime.t(),
            last_race: String.t(),
            practice: %{pos_integer() => pos_integer()},
            qualifiers: %{pos_integer() => list(pos_integer())},
            feature: %{pos_integer() => pos_integer()},
            timeout: pos_integer()
          }
    defstruct season: nil, watching: nil, watch_until: nil, last_race: nil, practice: %{}, qualifiers: %{}, feature: %{}, timeout: :timer.seconds(30)
  end

  def init({season, timeout}) do
    send(self(), :subscribe_listener)

    Logger.info("Season Analyzer for #{season.location.name} #{season.season} season (#{season.id}) online")

    {:ok, %State{season: season, timeout: timeout, watching: season_watch?(season)}}
  end

  defp via_tuple(season_id) do
    {:via, Registry, {KartVids.Registry, {__MODULE__, season_id}}}
  end

  def analyzer_state(id) when is_number(id), do: analyzer_state(via_tuple(id))
  def analyzer_state(%Season{id: id}), do: analyzer_state(via_tuple(id))

  def analyzer_state(pid_or_via_tuple) do
    GenServer.call(pid_or_via_tuple, :state)
  end

  def start_watching(id) when is_number(id), do: start_watching(via_tuple(id))
  def start_watching(%Season{id: id}), do: start_watching(via_tuple(id))

  def start_watching(pid_or_via_tuple) do
    GenServer.call(pid_or_via_tuple, :start_watching)
  end

  def stop_watching(id) when is_number(id), do: stop_watching(via_tuple(id))
  def stop_watching(%Season{id: id}), do: stop_watching(via_tuple(id))

  def stop_watching(pid_or_via_tuple) do
    GenServer.call(pid_or_via_tuple, :stop_watching)
  end

  def watching?(id) when is_number(id), do: watching?(via_tuple(id))
  def watching?(%Season{id: id}), do: watching?(via_tuple(id))

  def watching?(pid_or_via_tuple) do
    GenServer.call(pid_or_via_tuple, :watching?)
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @watch_length 8
  def handle_call(:start_watching, _from, state) do
    {:reply, true, %State{state | watching: Date.utc_today(), watch_until: Timex.add(DateTime.utc_now(), Timex.Duration.from_hours(@watch_length))}}
  end

  def handle_call(:stop_watching, _from, state) do
    {:reply, true, %State{state | watching: nil, watch_until: Timex.add(DateTime.utc_now(), Timex.Duration.from_hours(@watch_length))}}
  end

  def handle_call(:watching?, _from, state) do
    {:reply, watching_for_dates(state.watching, state.watch_until), state}
  end

  def handle_info(:subscribe_listener, state) do
    pid = RaceListener.whereis(state.season.location_id)

    if pid && Process.alive?(pid) && RaceListener.ping(pid) do
      %{last_race: last_race} = RaceListener.listener_state(state.season.location_id)
      RaceListener.subscribe(state.season.location_id)
      send(self(), :analyze_season)

      {:noreply, %State{state | last_race: last_race}}
    else
      Process.send_after(self(), :subscribe_listener, :timer.seconds(1))

      {:noreply, state}
    end
  end

  def handle_info(:analyze_season, state = %State{watching: watch_date, watch_until: watch_until, timeout: timeout, season: season = %Season{location_id: location_id}}) do
    Process.send_after(self(), :analyze_season, timeout)

    if watching_for_dates(watch_date, watch_until) do
      reloaded_season = watch_date |> Races.season_for_date(location_id)

      state =
        if reloaded_season do
          reloaded_season
          |> Races.league_races_for_season()
          # Most recent league meetup
          |> List.first()
          |> Map.get(:races)
          # Reset all practice/qualifiers/feature in order to reanalyze them given the current conditions, to dump any potentially bad analysis if data changed
          |> reduce_races_to_state(%State{state | season: reloaded_season, practice: %{}, qualifiers: %{}, feature: %{}})
          |> analyze_season()
        else
          # No races exist for watching date yet
          state
        end

      {:noreply, state}
    else
      # Check if we should start watching unless explicitly told (via watch_until using stop_watching) to not watch
      {:noreply, %State{state | watching: if(is_nil(watch_until), do: season_watch?(season), else: nil), watch_until: if(is_nil(watch_date) && watch_until, do: watch_until, else: nil), practice: %{}, qualifiers: %{}, feature: %{}}}
    end
  end

  # Ignore when not watching, just grab the last race ID to always track it
  def handle_info(%Phoenix.Socket.Broadcast{event: "race_completed", payload: %RaceListener.State{current_race: current_race}}, state = %State{watching: nil}) do
    {:noreply, %State{state | last_race: current_race}}
  end

  def handle_info(%Phoenix.Socket.Broadcast{}, state = %State{watching: nil}) do
    {:noreply, state}
  end

  # Ignore data while race is ongoing
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "race_data", payload: %RaceListener.State{config: %RaceListener.Config{location_id: location_id}}},
        state = %State{season: %Season{location_id: location_id}, watching: %Date{}}
      ) do
    {:noreply, state}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "race_completed", payload: %RaceListener.State{current_race: current_race}},
        state = %State{watching: %Date{}}
      ) do
    {:noreply, %State{state | last_race: current_race} |> analyze_season()}
  end

  def handle_info(msg, state) do
    Logger.warning("Season #{state.season.id}: Unknown message received, ignoring: #{inspect(msg)}\nWith state: #{inspect(state)}")

    {:noreply, state}
  end

  def reduce_races_to_state(races, analyzer_state = %State{}) do
    races
    |> Enum.sort_by(& &1.started_at, {:asc, DateTime})
    |> Enum.reduce(analyzer_state, fn race, state ->
      case update_state_for_race(state, race) do
        {:ok, new_state} -> new_state
        :ignore -> state
      end
    end)
  end

  defp analyze_season(state = %State{last_race: last_race, season: season, watching: %Date{}}) do
    race = Races.get_race_by_external_id(last_race, season.location)

    new_state =
      if race do
        race = Races.race_with_racers(race)

        season_racers = season.season_racers |> Enum.reduce(MapSet.new(), &MapSet.put(&2, &1.id))

        if Enum.count(race.racers, &MapSet.member?(season_racers, &1.racer_profile_id)) >= @minimum_racers do
          case update_state_for_race(state, race) do
            {:ok, state} ->
              updated = update_race(race, state.practice, Race.league_type_practice(), season.id)
              updated = updated || update_race(race, state.qualifiers, Race.league_type_qualifier(), season.id)
              practice_or_qualifier = updated
              updated = updated || update_race(race, state.feature, Race.league_type_feature(), season.id)

              if updated && !practice_or_qualifier do
                mark_win_by_position(race)
              end

              # These are racers which need to be added if they don't already exist
              if updated do
                for racer <- race.racers do
                  Races.create_season_racer(season, racer.racer_profile_id)
                end
              end

              state

            :ignore ->
              nil
          end
        end
      end

    # If state was updated return otherwise return existing state
    new_state || state
  end

  # Only update if the league type is set to none
  defp update_race(race = %Race{id: id, league_type: :none}, tracking, type, season_id) do
    tracking
    # Use find for early exit since no need to keep iterating
    |> Enum.find(fn
      {_profile_id, ^id} ->
        Races.update_race(:system, race, %{league?: true, league_type: type, season_id: season_id})

      {_profile_id, race_ids = %MapSet{}} ->
        if MapSet.member?(race_ids, id) do
          Races.update_race(:system, race, %{league?: true, league_type: type, season_id: season_id})
        end

      _ ->
        false
    end)
    |> then(&(!!&1))
  end

  # League type is already set, no need to change anything
  defp update_race(_race, _tracking, _type, _season_id), do: nil

  defp mark_win_by_position(race) do
    for racer <- race.racers do
      {:ok, _} = Races.update_racer(:system, racer, %{win_by: :position})
    end
  rescue
    e ->
      Logger.error("Ignoring failure to mark as win by position: #{e}")
  end

  def season_watch?(season = %Season{location: %Location{}}) do
    KartVids.Races.meetup_date(season, DateTime.utc_now())
  end

  def update_state_for_race(state, race) do
    cond do
      # Less than minimum racers did not get their practice race and all racers are missing a qualifier
      racers_in_map(race.racers, state.practice, race.id) == 0 && map_size(state.qualifiers) == 0 && map_size(state.feature) == 0 ->
        state =
          Enum.reduce(race.racers, state, fn racer, state ->
            put_in(state, [Access.key!(:practice), racer.racer_profile_id], race.id)
          end)

        {:ok, state}

      # Any racer did not get all their qualifiers
      racers_in_mapset(race.racers, state.qualifiers, state.season.daily_qualifiers, race.id) >= @minimum_racers && map_size(state.feature) == 0 ->
        state =
          Enum.reduce(race.racers, state, fn racer, state ->
            {_, new_state} =
              get_and_update_in(state, [Access.key!(:qualifiers), racer.racer_profile_id], fn v ->
                {v, MapSet.put(v || MapSet.new(), race.id)}
              end)

            new_state
          end)

        {:ok, state}

      # Less than minimum racers did not get their feature race -- cannot use win by position as this is sometimes not set correctly
      racers_in_map(race.racers, state.feature, race.id) < @minimum_racers ->
        state =
          Enum.reduce(race.racers, state, fn racer, state ->
            put_in(state, [Access.key!(:feature), racer.racer_profile_id], race.id)
          end)

        {:ok, state}

      true ->
        # This is not a race we should be considering since it did not fit anywhere into the bucketing strategy
        # Usually these are races after the final feature race so just ignore it
        :ignore
    end
  end

  def racers_in_map(racers, practice_feature_map, race_id) do
    Enum.count(racers, &(Map.get(practice_feature_map, &1.racer_profile_id, race_id) != race_id))
  end

  def racers_in_mapset(racers, qualifying_map, qualifiers, race_id) do
    Enum.count(racers, &(Map.get(qualifying_map, &1.racer_profile_id, MapSet.new()) |> Enum.filter(fn qual_race_id -> qual_race_id != race_id end) |> length() < qualifiers))
  end

  defp watching_for_dates(watch_date, watch_until) do
    watch_date && (is_nil(watch_until) || Timex.before?(DateTime.utc_now(), watch_until))
  end
end
