defmodule KartVids.Races.Season.AnalyzerTest do
  use KartVids.DataCase

  alias KartVids.RacesFixtures
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
    assert %Analyzer.State{watching: true} = Analyzer.analyzer_state(pid)
  end

  describe "race completed" do
    setup context do
      {:ok, pid} = Analyzer.start_link(context.season)
      %{analyzer: pid}
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

  describe "analyze season" do
    test "" do
    end
  end
end
