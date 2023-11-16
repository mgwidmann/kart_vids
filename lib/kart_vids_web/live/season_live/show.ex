defmodule KartVidsWeb.SeasonLive.Show do
  alias KartVids.Races.RacerProfile
  alias KartVids.Races.Season
  use KartVidsWeb, :live_view

  alias KartVids.Races
  import KartVids.SeasonLive.Helper

  embed_templates("racer/*")

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "id" => id}, _, socket) do
    season = Races.get_season!(id) |> with_racers() |> augment_season_racers() |> sort_season_racers()
    leagues = Races.league_races_for_season(season)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:leagues, leagues)
      |> assign(:season, season)
    }
  end

  defp sort_season_racers(season) do
    racers =
      season.season_racers
      |> Enum.sort_by(& &1.fastest_lap_time)

    %Season{season | season_racers: racers}
  end

  defp with_racers(season) do
    %Season{season | season_races: Races.race_with_racers(season.season_races)}
  end

  defp augment_season_racers(season) do
    fastest_racer_times =
      for season_racer <- season.season_racers, race <- Enum.filter(season.season_races, fn r -> Enum.find(r.racers, fn a -> a.racer_profile_id == season_racer.id end) end) do
        racer = Enum.find(race.racers, &(&1.racer_profile_id == season_racer.id))
        {season_racer.id, racer.fastest_lap}
      end
      |> Enum.group_by(fn {racer_profile_id, _fastest_lap} -> racer_profile_id end, fn {_racer_profile_id, fastest_lap} -> fastest_lap end)
      |> Enum.map(fn {racer_profile_id, lap_times} -> {racer_profile_id, lap_times |> KartVids.Karts.quality_filter(season.location, 1.0, & &1) |> Enum.min(&<=/2, fn -> Enum.min(lap_times) end)} end)
      |> Enum.into(%{})

    %Season{season | season_racers: Enum.map(season.season_racers, fn season_racer -> %RacerProfile{season_racer | fastest_lap_time: fastest_racer_times[season_racer.id]} end)}
  end

  defp page_title(:show), do: "Show Season"
  defp page_title(:edit), do: "Edit Season"
end
