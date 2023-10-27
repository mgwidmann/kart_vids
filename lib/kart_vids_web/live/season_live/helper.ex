defmodule KartVids.SeasonLive.Helper do
  alias KartVids.Races.Season

  def season_name(%Season{start_at: %Date{year: year}, season: season, driver_type: driver_type}) do
    "#{year} #{season |> Phoenix.Naming.humanize()} #{driver_type |> Phoenix.Naming.humanize()}"
  end
end
