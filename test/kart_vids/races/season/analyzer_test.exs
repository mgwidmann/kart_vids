defmodule KartVids.Races.Season.AnalyzerTest do
  use KartVids.DataCase

  alias KartVids.ContentFixtures
  alias KartVids.RacesFixtures
  alias KartVids.Races.Season
  alias KartVids.Races.Season.Analyzer
  alias KartVids.Races.Listener

  def listener_agent(location_id) do
    {:via, Registry, {KartVids.Registry, {Listener.State, location_id}}}
  end

  def setup_listener(_context) do
    season = RacesFixtures.season_fixture()
    {:ok, agent} = Agent.start_link(fn -> %{last_race: "123"} end, name: listener_agent(season.location_id))

    %{location: season.location, season: season, agent: agent}
  end

  setup :setup_listener

  test "starts up with a location", %{season: season} do
    assert {:ok, _pid} = Analyzer.start_link(season)
  end

  describe "Race Completed" do
    setup context do
      {:ok, pid} = Analyzer.start_link(context.season)
      %{analyzer: pid}
    end

    test "not watching keeps track of the current race", %{analyzer: analyzer, season: season} do
      send(analyzer, %Phoenix.Socket.Broadcast{event: "race_completed", payload: %Listener.State{current_race: "current-race"}})
      assert %Analyzer.State{last_race: "current-race"} = Analyzer.analyzer_state(season)
    end
  end

  describe "Analyzer Season" do
    test "" do
    end
  end
end
