defmodule KartVids.Races.Season.Analyzer do
  @moduledoc false
  use GenServer
  require Logger

  # alias KartVids.Races.League
  alias KartVids.Races
  alias KartVids.Content.Location
  alias KartVids.Races.{Season, Race, RacerProfile}
  alias KartVids.Races.Listener, as: RaceListener

  def start_link(season, timeout \\ :timer.seconds(30))

  # Check that the location and season_racers relation is loaded, either no racers or one struct which is a %SeasonRacer{}
  def start_link(%Season{location: %Location{}, season_racers: []} = season, timeout) do
    do_start_link(season, timeout)
  end

  def start_link(%Season{location: %Location{}, season_racers: [%RacerProfile{} | _]} = season, timeout) do
    do_start_link(season, timeout)
  end

  defp do_start_link(season, timeout) do
    GenServer.start_link(__MODULE__, {season, timeout}, name: via_tuple(season.id))
  end

  defmodule State do
    @type t :: %State{
            season: Season.t(),
            watching: boolean(),
            watch_until: DateTime.t(),
            last_race: String.t(),
            practice: %{pos_integer() => pos_integer()},
            qualifiers: %{pos_integer() => list(pos_integer())},
            feature: %{pos_integer() => pos_integer()},
            timeout: pos_integer()
          }
    defstruct season: nil, watching: false, watch_until: nil, last_race: nil, practice: %{}, qualifiers: %{}, feature: %{}, timeout: :timer.seconds(5)
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

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @watch_length 8
  def handle_call(:start_watching, _from, state) do
    {:reply, true, %State{state | watching: true, watch_until: Timex.add(DateTime.utc_now(), Timex.Duration.from_hours(@watch_length))}}
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

  def handle_info(:analyze_season, state = %State{last_race: last_race, season: season, watch_until: watch_until, practice: practice, qualifiers: qualifiers, feature: feature, timeout: timeout}) do
    Process.send_after(self(), :analyze_season, timeout)

    if season_watch?(season) || (watch_until && Timex.before?(DateTime.utc_now(), watch_until)) do
      race = Races.get_race_by_external_id(last_race) |> Races.race_with_racers()

      if race do
        # These are racers which need to be added if they don't already exist
        # if Enum.any?(race.racers, &(&1.win_by == :position)) do
        #   Logger.info("Racer profiles must be added to the season!")

        #   for racer <- race.racers do
        #     Races.create_season_racer(season, racer.racer_profile_id)
        #   end
        # end

        update_race(race, practice, Race.league_type_practice())
        update_race(race, qualifiers, Race.league_type_qualifier())
        update_race(race, feature, Race.league_type_feature())
      end

      {:noreply, %State{state | watching: true}}
    else
      {:noreply, %State{state | watching: false, watch_until: nil, practice: %{}, qualifiers: %{}, feature: %{}}}
    end
  end

  # Ignore when not watching, just grab the last race ID to always track it
  def handle_info(%Phoenix.Socket.Broadcast{event: "race_completed", payload: %RaceListener.State{current_race: current_race}}, state = %State{watching: false}) do
    {:noreply, %State{state | last_race: current_race}}
  end

  def handle_info(%Phoenix.Socket.Broadcast{}, state = %State{watching: false}) do
    {:noreply, state}
  end

  # Ignore data while race is ongoing
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "race_data", payload: %RaceListener.State{current_race: current_race, config: %RaceListener.Config{location_id: location_id}}},
        state = %State{season: %Season{location_id: location_id}, watching: true}
      ) do
    {:noreply, %{state | last_race: current_race}}
  end

  @minimum_racers 3
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "race_completed", payload: %RaceListener.State{current_race: current_race, config: %RaceListener.Config{location_id: location_id}, win_by: win_by}},
        state = %State{season: %Season{location_id: location_id, season_racers: racers}, watching: true}
      ) do
    profile_ids = racers |> Enum.map(& &1.id) |> MapSet.new()
    race = Races.get_race_by_external_id!(current_race) |> Races.race_with_racers()

    state =
      if Enum.count(race.racers, &MapSet.member?(profile_ids, &1.racer_profile_id)) >= @minimum_racers || win_by == "position" do
        state = update_state_for_race(state, race)

        # Process now
        send(self(), :analyze_season)

        state
      else
        state
      end

    {:noreply, %State{state | last_race: current_race}}
  end

  def handle_info(msg, state) do
    Logger.warning("Season #{state.season.id}: Unknown message received, ignoring: #{inspect(msg)}\nWith state: #{inspect(state)}")

    {:noreply, state}
  end

  # Only update if the league type is set to none
  defp update_race(race = %Race{id: id, league_type: :none}, tracking, type) do
    tracking
    # Use find for early exit since no need to keep iterating
    |> Enum.find(fn
      {_profile_id, ^id} ->
        Races.update_race(:system, race, %{league?: true, league_type: type})

      {_profile_id, race_ids = %MapSet{}} ->
        if MapSet.member?(race_ids, id) do
          Races.update_race(:system, race, %{league?: true, league_type: type})
        end

      _ ->
        false
    end)
  end

  defp update_race(_race, _tracking, _type), do: nil

  def season_watch?(season = %Season{}) do
    KartVids.Races.meetup_date(season, DateTime.utc_now()) != nil
  end

  def update_state_for_race(state, race) do
    cond do
      # Any racer did not get their practice race
      !Enum.any?(race.racers, &Map.get(state.practice, &1.racer_profile_id)) ->
        Enum.reduce(race.racers, state, fn racer, state ->
          put_in(state, [Access.key!(:practice), racer.racer_profile_id], race.id)
        end)

      # Any racer did not get all their qualifiers
      Enum.any?(race.racers, &(Map.get(state.qualifiers, &1.racer_profile_id, MapSet.new()) |> MapSet.size() < state.season.daily_qualifiers)) ->
        Enum.reduce(race.racers, state, fn racer, state ->
          {_, new_state} =
            get_and_update_in(state, [Access.key!(:qualifiers), racer.racer_profile_id], fn v ->
              {v, MapSet.put(v || MapSet.new(), race.id)}
            end)

          new_state
        end)

      # Any racer did not get their feature race
      !Enum.any?(race.racers, &Map.get(state.feature, &1.racer_profile_id)) && race.racers |> Enum.all?(&(&1.win_by == :position)) ->
        Enum.reduce(race.racers, state, fn racer, state ->
          put_in(state, [Access.key!(:feature), racer.racer_profile_id], race.id)
        end)

      true ->
        IO.puts("Unable to update state for race #{race.id}: #{inspect(race.racers |> Enum.map(& &1.win_by))}")
        state
    end
  end
end
