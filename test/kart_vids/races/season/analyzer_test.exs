defmodule KartVids.Races.Season.AnalyzerTest do
  use KartVids.DataCase

  alias KartVids.RacesFixtures
  alias KartVids.Races
  alias KartVids.Races.Season
  alias KartVids.Races.Season.Analyzer
  alias KartVids.Races.Listener

  def listener_agent(location_id) do
    {:via, Registry, {KartVids.Registry, {Listener.State, location_id}}}
  end

  def setup_listener(_context) do
    season = RacesFixtures.season_fixture()
    race = RacesFixtures.race_fixture()
    {:ok, agent} = Agent.start_link(fn -> %{last_race: race.external_race_id} end, name: listener_agent(season.location_id))

    %{location: season.location, season: season, agent: agent, last_race: race}
  end

  setup :setup_listener

  test "starts up with a location", %{season: season} do
    assert {:ok, pid} = Analyzer.start_link(season)
    assert %Analyzer.State{watching: %Date{}} = Analyzer.analyzer_state(pid)
  end

  describe "while running" do
    setup context do
      {:ok, pid} = Analyzer.start_link(context.season)
      %{analyzer: pid}
    end

    test "starts watching", %{analyzer: analyzer, season: season, location: location} do
      # A new race just finished
      race = RacesFixtures.race_fixture()
      send(analyzer, %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: race.external_race_id, config: %Listener.Config{location_id: location.id}, win_by: "laptime"}})

      # Assert that the newly finished race is the one that it recognizes
      recent_race_id = race.external_race_id
      assert %Analyzer.State{last_race: ^recent_race_id} = Analyzer.analyzer_state(season)
    end

    test "watching keeps track of the current race", %{analyzer: analyzer, season: season, location: location} do
      # A new race just finished
      race = RacesFixtures.race_fixture()
      send(analyzer, %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: race.external_race_id, config: %Listener.Config{location_id: location.id}, win_by: "laptime"}})

      # Assert that the newly finished race is the one that it recognizes
      recent_race_id = race.external_race_id
      assert %Analyzer.State{last_race: ^recent_race_id} = Analyzer.analyzer_state(season)
    end
  end

  describe "counting races" do
    test "adds practice", %{season: season} do
      season_racers = season.season_racers |> Enum.shuffle() |> Enum.take(5)
      {race, profile_ids} = RacesFixtures.create_season_race("10 Lap Junior Practice Race", :laps, :laptime, season_racers)

      last_race = race.external_race_id
      practice = profile_ids |> Stream.map(fn id -> {id, race.id} end) |> Enum.into(%{})

      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: %{}, feature: %{}}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: race.external_race_id, config: %Listener.Config{location_id: season.location_id}, win_by: "laptime"}},
                 %Analyzer.State{season: season, practice: %{}, qualifiers: %{}, feature: %{}, watching: Date.utc_today()}
               )

      # Every second a broadcast occurs, make sure the data doesn't change
      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: %{}, feature: %{}}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: race.external_race_id, config: %Listener.Config{location_id: season.location_id}, win_by: "laptime"}},
                 %Analyzer.State{season: season, practice: %{}, qualifiers: %{}, feature: %{}, watching: Date.utc_today()}
               )
    end

    test "adds qualifier", %{season: season} do
      season_racers = season.season_racers |> Enum.shuffle() |> Enum.take(5)
      {practice_race, _profile_ids} = RacesFixtures.create_season_race("Practice Race", :laps, :laptime, season_racers)
      {qualifying_race, profile_ids} = RacesFixtures.create_season_race("Qualifying Race", :laps, :laptime, season_racers)

      last_race = qualifying_race.external_race_id
      # These racers already did a practice race
      practice = profile_ids |> Stream.map(fn id -> {id, practice_race.id} end) |> Enum.into(%{})
      expected_qualifiers = profile_ids |> Stream.map(fn id -> {id, MapSet.new([qualifying_race.id])} end) |> Enum.into(%{})
      feature = %{}

      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^expected_qualifiers, feature: ^feature}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: qualifying_race.external_race_id, config: %Listener.Config{location_id: season.location_id}, win_by: "laptime"}},
                 %Analyzer.State{season: season, practice: practice, qualifiers: %{}, feature: feature, watching: Date.utc_today()}
               )

      # Every second a broadcast occurs, make sure the data doesn't change
      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^expected_qualifiers, feature: ^feature}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: qualifying_race.external_race_id, config: %Listener.Config{location_id: season.location_id}, win_by: "laptime"}},
                 %Analyzer.State{season: season, practice: practice, qualifiers: %{}, feature: feature, watching: Date.utc_today()}
               )
    end

    test "adds 2nd qualifier", %{season: season} do
      season_racers = season.season_racers |> Enum.shuffle() |> Enum.take(5)
      {practice_race, _profile_ids} = RacesFixtures.create_season_race("Practice Race", :laps, :laptime, season_racers)
      {qualifying_race, _profile_ids} = RacesFixtures.create_season_race("Qualifying Race", :laps, :laptime, season_racers)
      {qualifying_race_2, profile_ids} = RacesFixtures.create_season_race("Qualifying Race", :laps, :laptime, season_racers)

      last_race = qualifying_race_2.external_race_id
      # These racers already did a practice and a single qualifying race
      practice = profile_ids |> Stream.map(fn id -> {id, practice_race.id} end) |> Enum.into(%{})
      qualifiers = profile_ids |> Stream.map(fn id -> {id, MapSet.new([qualifying_race.id])} end) |> Enum.into(%{})
      expected_qualifiers = profile_ids |> Stream.map(fn id -> {id, MapSet.new([qualifying_race.id, qualifying_race_2.id])} end) |> Enum.into(%{})
      feature = %{}

      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^expected_qualifiers, feature: ^feature}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: qualifying_race_2.external_race_id, config: %Listener.Config{location_id: season.location_id}, win_by: "laptime"}},
                 %Analyzer.State{season: season, practice: practice, qualifiers: qualifiers, feature: feature, watching: Date.utc_today()}
               )

      # Every second a broadcast occurs, make sure the data doesn't change
      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^expected_qualifiers, feature: ^feature}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: qualifying_race_2.external_race_id, config: %Listener.Config{location_id: season.location_id}, win_by: "laptime"}},
                 %Analyzer.State{season: season, practice: practice, qualifiers: qualifiers, feature: feature, watching: Date.utc_today()}
               )
    end

    test "adds feature", %{season: season} do
      season_racers = season.season_racers |> Enum.shuffle() |> Enum.take(5)
      {practice_race, _profile_ids} = RacesFixtures.create_season_race("Practice Race", :laps, :laptime, season_racers)
      {qualifying_race, _profile_ids} = RacesFixtures.create_season_race("Qualifying Race", :laps, :laptime, season_racers)
      {qualifying_race_2, _profile_ids} = RacesFixtures.create_season_race("Qualifying Race", :laps, :laptime, season_racers)
      {feature_race, profile_ids} = RacesFixtures.create_season_race("AEKC Race", :laps, :position, season_racers)

      last_race = feature_race.external_race_id
      # These racers already did a practice and qualifying race
      practice = profile_ids |> Stream.map(fn id -> {id, practice_race.id} end) |> Enum.into(%{})
      qualifiers = profile_ids |> Stream.map(fn id -> {id, MapSet.new([qualifying_race.id, qualifying_race_2.id])} end) |> Enum.into(%{})
      expected_feature = profile_ids |> Stream.map(fn id -> {id, feature_race.id} end) |> Enum.into(%{})

      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^qualifiers, feature: ^expected_feature}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: feature_race.external_race_id, config: %Listener.Config{location_id: season.location_id}, win_by: "position"}},
                 %Analyzer.State{season: season, practice: practice, qualifiers: qualifiers, feature: %{}, watching: Date.utc_today()}
               )

      # Every second a broadcast occurs, make sure the data doesn't change
      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^qualifiers, feature: ^expected_feature}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: feature_race.external_race_id, config: %Listener.Config{location_id: season.location_id}, win_by: "position"}},
                 %Analyzer.State{season: season, practice: practice, qualifiers: qualifiers, feature: %{}, watching: Date.utc_today()}
               )
    end
  end

  describe "updating the race" do
    test "updates practice", %{season: season} do
      season_id = season.id
      season_racers = season.season_racers |> Enum.shuffle() |> Enum.take(5)
      {practice_race, profile_ids} = RacesFixtures.create_season_race("10 Lap Junior Practice Race", :laps, :laptime, season_racers)

      last_race = practice_race.external_race_id
      practice = profile_ids |> Stream.map(fn id -> {id, practice_race.id} end) |> Enum.into(%{})

      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: %{}, feature: %{}}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: last_race}},
                 %Analyzer.State{last_race: last_race, season: season, practice: practice, qualifiers: %{}, feature: %{}, watching: Date.utc_today(), timeout: :timer.seconds(30)}
               )

      assert %Races.Race{league?: true, league_type: :practice, season_id: ^season_id} = Races.get_race!(practice_race.id)

      # When runs a little later, make sure the data doesn't change
      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: %{}, feature: %{}}} =
               Analyzer.handle_info(
                 :analyze_season,
                 %Analyzer.State{last_race: last_race, season: season, practice: practice, qualifiers: %{}, feature: %{}, watching: Date.utc_today(), timeout: :timer.seconds(30)}
               )

      assert %Races.Race{league?: true, league_type: :practice, season_id: ^season_id} = Races.get_race!(practice_race.id)
    end

    test "updates qualifier", %{season: season} do
      season_id = season.id
      season_racers = season.season_racers |> Enum.shuffle() |> Enum.take(5)
      {practice_race, _profile_ids} = RacesFixtures.create_season_race("Practice Race", :laps, :laptime, season_racers)
      {qualifying_race, profile_ids} = RacesFixtures.create_season_race("Qualifying Race", :laps, :laptime, season_racers)

      last_race = qualifying_race.external_race_id
      # These racers already did a practice race
      practice = profile_ids |> Stream.map(fn id -> {id, practice_race.id} end) |> Enum.into(%{})
      qualifiers = profile_ids |> Stream.map(fn id -> {id, MapSet.new([qualifying_race.id])} end) |> Enum.into(%{})
      feature = %{}

      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^qualifiers, feature: ^feature}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: last_race}},
                 %Analyzer.State{last_race: last_race, season: season, practice: practice, qualifiers: qualifiers, feature: %{}, watching: Date.utc_today(), timeout: :timer.seconds(30)}
               )

      assert %Races.Race{league?: true, league_type: :qualifier, season_id: ^season_id} = Races.get_race!(qualifying_race.id)

      # When runs a little later, make sure the data doesn't change
      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^qualifiers, feature: ^feature}} =
               Analyzer.handle_info(
                 :analyze_season,
                 %Analyzer.State{last_race: last_race, season: season, practice: practice, qualifiers: qualifiers, feature: %{}, watching: Date.utc_today(), timeout: :timer.seconds(30)}
               )

      assert %Races.Race{league?: true, league_type: :qualifier, season_id: ^season_id} = Races.get_race!(qualifying_race.id)
    end

    test "updates 2nd qualifier", %{season: season} do
      season_id = season.id
      season_racers = season.season_racers |> Enum.shuffle() |> Enum.take(5)
      {practice_race, _profile_ids} = RacesFixtures.create_season_race("Practice Race", :laps, :laptime, season_racers)
      {qualifying_race, _profile_ids} = RacesFixtures.create_season_race("Qualifying Race 1", :laps, :laptime, season_racers)
      {qualifying_race_2, profile_ids} = RacesFixtures.create_season_race("Qualifying Race 2", :laps, :laptime, season_racers)

      last_race = qualifying_race_2.external_race_id
      # These racers already did a practice and both qualifying races
      practice = profile_ids |> Stream.map(fn id -> {id, practice_race.id} end) |> Enum.into(%{})
      state_qualifiers = profile_ids |> Stream.map(fn id -> {id, MapSet.new([qualifying_race.id])} end) |> Enum.into(%{})
      qualifiers = profile_ids |> Stream.map(fn id -> {id, MapSet.new([qualifying_race.id, qualifying_race_2.id])} end) |> Enum.into(%{})
      feature = %{}

      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^qualifiers, feature: ^feature}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: last_race}},
                 %Analyzer.State{last_race: last_race, season: season, practice: practice, qualifiers: state_qualifiers, feature: %{}, watching: Date.utc_today(), timeout: :timer.seconds(30)}
               )

      assert %Races.Race{league?: true, league_type: :qualifier, season_id: ^season_id} = Races.get_race!(qualifying_race_2.id)

      # When runs a little later, make sure the data doesn't change
      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^qualifiers, feature: ^feature}} =
               Analyzer.handle_info(
                 :analyze_season,
                 %Analyzer.State{last_race: last_race, season: season, practice: practice, qualifiers: qualifiers, feature: %{}, watching: Date.utc_today(), timeout: :timer.seconds(30)}
               )

      assert %Races.Race{league?: true, league_type: :qualifier, season_id: ^season_id} = Races.get_race!(qualifying_race_2.id)
    end

    test "updates feature", %{season: season} do
      season_id = season.id
      season_racers = season.season_racers |> Enum.shuffle() |> Enum.take(5)
      {practice_race, _profile_ids} = RacesFixtures.create_season_race("Practice Race", :laps, :laptime, season_racers)
      {qualifying_race, _profile_ids} = RacesFixtures.create_season_race("Qualifying Race 1", :laps, :laptime, season_racers)
      {qualifying_race_2, _profile_ids} = RacesFixtures.create_season_race("Qualifying Race 2", :laps, :laptime, season_racers)
      {feature_race, profile_ids} = RacesFixtures.create_season_race("AEKC Race", :laps, :position, season_racers)

      last_race = feature_race.external_race_id
      # These racers already did a practice and qualifying race
      practice = profile_ids |> Stream.map(fn id -> {id, practice_race.id} end) |> Enum.into(%{})
      qualifiers = profile_ids |> Stream.map(fn id -> {id, MapSet.new([qualifying_race.id, qualifying_race_2.id])} end) |> Enum.into(%{})
      state_feature = %{}
      feature = profile_ids |> Stream.map(fn id -> {id, feature_race.id} end) |> Enum.into(%{})

      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^qualifiers, feature: ^feature}} =
               Analyzer.handle_info(
                 %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: last_race}},
                 %Analyzer.State{last_race: last_race, season: season, practice: practice, qualifiers: qualifiers, feature: state_feature, watching: Date.utc_today(), timeout: :timer.seconds(30)}
               )

      assert %Races.Race{league?: true, league_type: :feature, season_id: ^season_id} = Races.get_race!(feature_race.id)

      # When runs a little later, make sure the data doesn't change
      assert {:noreply, %Analyzer.State{last_race: ^last_race, practice: ^practice, qualifiers: ^qualifiers, feature: ^feature}} =
               Analyzer.handle_info(
                 :analyze_season,
                 %Analyzer.State{last_race: last_race, season: season, practice: practice, qualifiers: qualifiers, feature: feature, watching: Date.utc_today(), timeout: :timer.seconds(30)}
               )

      assert %Races.Race{league?: true, league_type: :feature, season_id: ^season_id} = Races.get_race!(feature_race.id)
    end
  end

  describe "updating state" do
    test "as it is replayed" do
      all_races = KartVids.SeasonAnalyzerFixture.league_races()

      # Practice 1 - 7 racers
      races = Enum.take(all_races, 1)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 10249, 15295, 18997, 19003, 21560, 33829] == Map.keys(state.practice)
      assert [] == Map.keys(state.qualifiers)
      assert [] == Map.keys(state.feature)

      # Practice 2 - 4 racers
      races = Enum.take(all_races, 2)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 199, 8211, 10249, 12532, 15295, 18997, 19003, 21560, 22375, 33829] == Map.keys(state.practice)
      assert [] == Map.keys(state.qualifiers)
      assert [] == Map.keys(state.feature)

      # Practice 3 - 4 racers
      races = Enum.take(all_races, 3)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 199, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 30420, 31622, 33829] == Map.keys(state.practice)
      assert [] == Map.keys(state.qualifiers)
      assert [] == Map.keys(state.feature)

      # Practice 4 - 5 racers
      races = Enum.take(all_races, 4)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)
      assert [] == Map.keys(state.qualifiers)
      assert [] == Map.keys(state.feature)

      # Qualifying 1 (Round 1) - 4 racers
      races = Enum.take(all_races, 5)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)
      assert [760, 27434, 31621, 31622] == Map.keys(state.qualifiers)
      assert [] == Map.keys(state.feature)

      # Qualifying 2 (Round 1) - 4 racers
      races = Enum.take(all_races, 6)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)
      assert [125, 760, 27434, 30420, 31618, 31619, 31621, 31622] == Map.keys(state.qualifiers)
      assert [] == Map.keys(state.feature)

      # Qualifying 3 (Round 1) - 5 racers
      races = Enum.take(all_races, 7)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)
      assert [125, 760, 18997, 19003, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31621, 31622] == Map.keys(state.qualifiers)
      assert [] == Map.keys(state.feature)

      # Qualifying 4 (Round 1) - 5 racers
      races = Enum.take(all_races, 8)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)
      assert [125, 199, 760, 8211, 10249, 12532, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31621, 31622] == Map.keys(state.qualifiers)
      assert [] == Map.keys(state.feature)

      # Qualifying 5 (Round 1) - 5 racers
      races = Enum.take(all_races, 9)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)
      assert [125, 132, 144, 199, 760, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31621, 31622, 33829] == Map.keys(state.qualifiers)
      assert [] == Map.keys(state.feature)

      # Qualifying 1 (Round 2) - 3 racers
      races = Enum.take(all_races, 10)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)
      assert [760, 27434, 31622] == state.qualifiers |> Enum.reject(fn {_racer_id, mapset} -> MapSet.size(mapset) == 1 end) |> Enum.into(%{}) |> Map.keys()
      assert [] == Map.keys(state.feature)

      # Qualifying 2 (Round 2) - 4 racers
      races = Enum.take(all_races, 11)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)
      assert [125, 760, 27434, 30420, 31618, 31619, 31622] == state.qualifiers |> Enum.reject(fn {_racer_id, mapset} -> MapSet.size(mapset) == 1 end) |> Enum.into(%{}) |> Map.keys()
      assert [] == Map.keys(state.feature)

      # Qualifying 3 (Round 2) - 5 racers
      races = Enum.take(all_races, 12)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)
      assert [125, 760, 18997, 19003, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622] == state.qualifiers |> Enum.reject(fn {_racer_id, mapset} -> MapSet.size(mapset) == 1 end) |> Enum.into(%{}) |> Map.keys()
      assert [] == Map.keys(state.feature)

      # Qualifying 4 (Round 2) - 5 racers
      races = Enum.take(all_races, 13)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)
      assert [125, 199, 760, 8211, 10249, 12532, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622] == state.qualifiers |> Enum.reject(fn {_racer_id, mapset} -> MapSet.size(mapset) == 1 end) |> Enum.into(%{}) |> Map.keys()
      assert [] == Map.keys(state.feature)

      # Qualifying 5 (Round 2) - 5 racers
      races = Enum.take(all_races, 14)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)

      assert [125, 132, 144, 199, 760, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622, 33829] ==
               state.qualifiers |> Enum.reject(fn {_racer_id, mapset} -> MapSet.size(mapset) == 1 end) |> Enum.into(%{}) |> Map.keys()

      assert [] == Map.keys(state.feature)

      # Feature 1 - 3 racers
      races = Enum.take(all_races, 15)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)

      assert [125, 132, 144, 199, 760, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622, 33829] ==
               state.qualifiers |> Enum.reject(fn {_racer_id, mapset} -> MapSet.size(mapset) == 1 end) |> Enum.into(%{}) |> Map.keys()

      assert [760, 27434, 31622] == Map.keys(state.feature)

      # Feature 2 - 4 racers
      races = Enum.take(all_races, 16)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)

      assert [125, 132, 144, 199, 760, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622, 33829] ==
               state.qualifiers |> Enum.reject(fn {_racer_id, mapset} -> MapSet.size(mapset) == 1 end) |> Enum.into(%{}) |> Map.keys()

      assert [760, 12532, 19003, 27434, 30420, 31618, 31622] == Map.keys(state.feature)

      # Feature 3 - 5 racers
      races = Enum.take(all_races, 17)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)

      assert [125, 132, 144, 199, 760, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622, 33829] ==
               state.qualifiers |> Enum.reject(fn {_racer_id, mapset} -> MapSet.size(mapset) == 1 end) |> Enum.into(%{}) |> Map.keys()

      assert [760, 12532, 18997, 19003, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622] == Map.keys(state.feature)

      # Feature 4 - 5 racers
      races = Enum.take(all_races, 18)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)

      assert [125, 132, 144, 199, 760, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622, 33829] ==
               state.qualifiers |> Enum.reject(fn {_racer_id, mapset} -> MapSet.size(mapset) == 1 end) |> Enum.into(%{}) |> Map.keys()

      assert [125, 144, 199, 760, 10249, 12532, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622] == Map.keys(state.feature)

      # Feature 5 - 5 racers
      races = Enum.take(all_races, 19)
      state = Analyzer.reduce_races_to_state(races, %Analyzer.State{season: %Season{daily_qualifiers: 2}, practice: %{}, qualifiers: %{}, feature: %{}})
      assert [125, 132, 144, 199, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27506, 30420, 31618, 31621, 31622, 33829] == Map.keys(state.practice)

      assert [125, 132, 144, 199, 760, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622, 33829] ==
               state.qualifiers |> Enum.reject(fn {_racer_id, mapset} -> MapSet.size(mapset) == 1 end) |> Enum.into(%{}) |> Map.keys()

      assert [125, 132, 144, 199, 760, 1915, 8211, 10249, 12532, 15295, 18997, 19003, 21380, 21560, 22375, 27434, 27506, 30420, 31618, 31619, 31622, 33829] == Map.keys(state.feature)
    end
  end
end
