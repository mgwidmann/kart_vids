defmodule KartVids.Races.Season.AnalyzerSupervisor do
  use DynamicSupervisor

  require Logger
  alias KartVids.Races
  alias KartVids.Races.Season.Analyzer

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    spawn_link(__MODULE__, :start_seasons, [])
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_season(season) do
    spec = %{id: Analyzer, start: {Analyzer, :start_link, [season]}, restart: :permanent}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def start_seasons() do
    Logger.info("Starting season analyzers which are active...")

    for season <- Races.list_seasons(true) do
      Logger.info("Starting season #{season.id}")
      start_season(season)
    end
  end
end
