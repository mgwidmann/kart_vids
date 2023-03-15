defmodule KartVids.Races.Season.Analyzer do
  use GenServer
  require Logger

  # alias KartVids.Races.League
  alias KartVids.Races
  alias KartVids.Content.Location
  alias KartVids.Races.{Season, Race}
  alias KartVids.Races.Listener, as: RaceListener

  def start_link(season) do
    GenServer.start_link(__MODULE__, season, [])
  end

  defmodule State do
    defstruct season: nil, watching: false, last_race: nil, practice: %{}, qualifiers: %{}, feature: %{}
  end

  def init(season) do
    send(self(), :analyze_season)
    %{last_race: last_race} = RaceListener.listener_state(season.location_id)
    RaceListener.subscribe(season.location_id)
    {:ok, %State{season: season, last_race: last_race}}
  end

  @analyze_season_timeout :timer.seconds(30)

  def handle_info(:analyze_season, state = %State{last_race: nil}) do
    Process.send_after(self(), :analyze_season, :timer.seconds(5))

    {:noreply, state}
  end

  def handle_info(:analyze_season, state = %State{last_race: last_race, season: season, practice: practice, qualifiers: qualifiers, feature: feature}) do
    Process.send_after(self(), :analyze_season, @analyze_season_timeout)

    if season_watch?(season) do
      Logger.info("Analyzing season: #{inspect(season)}")

      race = Races.get_race_by_external_id!(last_race) |> Races.race_with_racers()
      # These are racers which need to be added if they don't already exist
      if Enum.any?(race.racers, &(&1.win_by == :position)) do
        Logger.info("Racer profiles must be added to the season!")

        for racer <- race.racers do
          Races.create_season_racer(season, racer.racer_profile_id)
        end
      end

      update_race(race, practice, Race.league_type_practice())
      update_race(race, qualifiers, Race.league_type_qualifier())
      update_race(race, feature, Race.league_type_feature())

      {:noreply, %State{state | watching: true}}
    else
      {:noreply, %State{state | watching: false, practice: %{}, qualifiers: %{}, feature: %{}}}
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
        %Phoenix.Socket.Broadcast{event: "race_completed", payload: %RaceListener.State{config: %RaceListener.Config{location_id: location_id}}},
        state = %State{last_race: current_race, season: %Season{location_id: location_id, season_racers: racers, daily_qualifiers: daily_qualifiers}, practice: practice, qualifiers: qualifiers, feature: feature, watching: true}
      ) do
    profile_ids = racers |> Enum.map(& &1.id) |> MapSet.new()
    race = Races.get_race_by_external_id!(current_race) |> Races.race_with_racers()

    state =
      if Enum.count(race.racers, &MapSet.member?(profile_ids, &1.racer_profile_id)) >= @minimum_racers do
        cond do
          # Any racer did not get their practice race
          !Enum.any?(race.racers, &Map.get(practice, &1.id)) ->
            Enum.reduce(race.racers, state, fn racer, state ->
              put_in(state, [:practice, racer.racer_profile_id], race.id)
            end)

          # Any racer did not get all their qualifiers
          !Enum.any?(race.racers, &(Map.get(qualifiers, &1.id, []) |> length() < daily_qualifiers)) ->
            Enum.reduce(race.racers, state, fn racer, state ->
              get_and_update_in(state, [:qualifiers, racer.racer_profile_id], fn v ->
                {v, [race.id | v || []]}
              end)
            end)

          # Any racer did not get their feature race
          !Enum.any?(race.racers, &(Map.get(feature, &1.id, []) |> length() < daily_qualifiers)) ->
            Enum.reduce(race.racers, state, fn racer, state ->
              put_in(state, [:feature, racer.racer_profile_id], race.id)
            end)

          true ->
            state
        end
      else
        state
      end

    {:noreply, %State{state | last_race: current_race}}
  end

  def handle_info(msg, state) do
    Logger.warn("Season #{state.season.id}: Unknown message received, ignoring: #{inspect(msg)}")

    {:noreply, state}
  end

  def update_race(race = %Race{id: id}, tracking, type) do
    tracking
    |> Enum.find(fn
      {_profile_id, ^id} ->
        Races.update_race(:system, race, %{league?: true, league_type: type})

      {_profile_id, race_ids} when is_list(race_ids) ->
        if Enum.any?(race_ids, &match?(^id, &1)) do
          Races.update_race(:system, race, %{league?: true, league_type: type})
        end

      _ ->
        false
    end)
  end

  @watch_window 6

  def season_watch?(%Season{start_at: start_at, ended: ended, weekly_start_day: weekly_start_day, weekly_start_at: weekly_start_at, location: %Location{timezone: timezone}}) do
    now = DateTime.utc_now()
    today = DateTime.to_date(now)
    yesterday = DateTime.add(now, -1, :day) |> DateTime.to_date()

    today_dow = Date.day_of_week(today) |> Season.weekly_start_day()
    yesterday_dow = Date.day_of_week(yesterday) |> Season.weekly_start_day()

    today_start_at = NaiveDateTime.new!(today, weekly_start_at) |> DateTime.from_naive!(timezone)
    yesterday_start_at = NaiveDateTime.new!(yesterday, weekly_start_at) |> DateTime.from_naive!(timezone)

    Date.diff(today, start_at) > 0 && !ended &&
      ((weekly_start_day == today_dow && Timex.between?(now, today_start_at, Timex.add(today_start_at, Timex.Duration.from_hours(@watch_window)))) ||
         (weekly_start_day == yesterday_dow && Timex.between?(now, yesterday_start_at, Timex.add(yesterday_start_at, Timex.Duration.from_hours(@watch_window)))))
  end
end
