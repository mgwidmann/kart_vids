defmodule KartVids.Races.Season.Analyzer do
  use GenServer

  alias KartVids.Races.League
  alias KartVids.Races

  def start_link(season) do
    GenServer.start_link(__MODULE__, [season], [])
  end

  def init(season) do
    send(self(), :analyze_season)
    {:ok, %{season: season}}
  end

  def handle_info(:analyze_season, state = %{season: season}) do
    for %League{date: date, racer_names: racer_names} <- Races.leagues() do
      Date.day_of_week(date)
    end

    {:noreply, state}
  end
end
