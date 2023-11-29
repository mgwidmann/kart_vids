defmodule KartVidsWeb.SeasonLive.Show do
  alias KartVids.Races.Season.Analyzer
  alias KartVids.Races.RacerProfile
  alias KartVids.Races.Season
  alias KartVids.Content.Location
  use KartVidsWeb, :live_view

  alias KartVids.Races
  import KartVids.SeasonLive.Helper

  embed_templates("racer/*")

  @update_analyzer_state :timer.seconds(10)

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "id" => id} = params, _, socket) do
    season = Races.get_season!(id) |> with_racers() |> augment_season_racers() |> sort_season_racers()
    leagues = Races.league_races_for_season(season)

    if socket.assigns.current_user && socket.assigns.current_user.admin? && params["watch"] do
      case params["watch"] do
        "true" ->
          Analyzer.start_watching(season)

        "false" ->
          Analyzer.stop_watching(season)

        _ ->
          nil
      end
    end

    analyzer_state = load_analyzer_state(season, leagues)
    Process.send_after(self(), :update_analyzer_state, @update_analyzer_state)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:leagues, leagues)
      |> assign(:analyzer_state, analyzer_state)
      |> assign(:season, season)
    }
  end

  @impl true
  def handle_info(:update_analyzer_state, socket) do
    season = Races.get_season!(socket.assigns.season.id) |> with_racers() |> augment_season_racers() |> sort_season_racers()
    leagues = Races.league_races_for_season(season)

    analyzer_state = load_analyzer_state(season, leagues)
    Process.send_after(self(), :update_analyzer_state, @update_analyzer_state)

    {
      :noreply,
      socket
      |> assign(:season, season)
      |> assign(:leagues, leagues)
      |> assign(:analyzer_state, analyzer_state)
    }
  end

  @impl true
  def handle_event("delete", %{"season_racer_id" => racer_profile_id}, socket) do
    Races.delete_season_racer(racer_profile_id)

    {
      :noreply,
      socket
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

  defp load_analyzer_state(season = %Season{location: %Location{}}, leagues) do
    analyzer_state = Analyzer.analyzer_state(season)

    analyzer_state =
      if Analyzer.watching?(season) do
        analyzer_state
      else
        leagues
        |> List.first()
        |> Map.get(:races)
        |> Enum.sort_by(& &1.started_at, {:asc, DateTime})
        |> Enum.reduce(analyzer_state, fn race, state -> Analyzer.update_state_for_race(state, race) end)
      end

    analyzer_state
  end

  def check_or_x_link(location_id, analyzer_state, racer_id, qualifier_number \\ nil)

  def check_or_x_link(location_id, analyzer_state, racer_id, qualifier_number) when not is_nil(qualifier_number) and qualifier_number >= 0 do
    mapset = analyzer_state[racer_id] || MapSet.new()
    race_id = Enum.at(MapSet.to_list(mapset), qualifier_number)
    check_or_x_link(location_id, %{racer_id => race_id}, racer_id, nil)
  end

  def check_or_x_link(location_id, analyzer_state, racer_id, qualifier_number) do
    assigns = %{location_id: location_id, analyzer_state: analyzer_state, racer_id: racer_id, qualifier_number: qualifier_number}

    ~H"""
    <%= if @analyzer_state[@racer_id] do %>
      <.link id={@qualifier_number} navigate={~p"/locations/#{@location_id}/races/#{@analyzer_state[@racer_id]}"}>✔️</.link>
    <% else %>
      ❌
    <% end %>
    """
  end
end
