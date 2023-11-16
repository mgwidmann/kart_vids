defmodule KartVidsWeb.RaceLive.League do
  use KartVidsWeb, :live_view
  require Logger
  import KartVidsWeb.Components.Racing

  alias KartVids.Content
  alias KartVids.Races
  alias KartVids.Races.Listener
  alias KartVids.Races.Season.Analyzer
  alias KartVids.Races.{Race, Racer}
  import KartVids.SeasonLive.Helper

  embed_templates "races/*"
  embed_templates "../racer_live/racer/*"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "date" => date} = params, _url, socket) do
    location = socket.assigns[:location] || Content.get_location!(location_id)
    {:ok, date} = Date.from_iso8601(date)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:location, location)
      |> assign(:date, date)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  @impl true
  @spec handle_info(Phoenix.Socket.Broadcast.t(), Phoenix.LiveView.Socket.t()) :: {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info(
        %Phoenix.Socket.Broadcast{event: event, payload: %KartVids.Races.Listener.State{racers: racers}},
        socket
      )
      when event in ["race_data", "race_completed"] do
    first_race = Races.league_races_on_date(Date.utc_today()) |> List.first()

    qualifying =
      if first_race && first_race.season && Analyzer.season_watch?(first_race.season) do
        racers
        |> Map.values()
        |> Enum.reduce(socket.assigns.qualifying, fn racer, q ->
          q
          |> Enum.map(fn qracer ->
            if qracer.nickname == racer.nickname do
              %Racer{qracer | fastest_lap: Enum.min([qracer.fastest_lap, racer.fastest_lap])}
            else
              qracer
            end
          end)
        end)
        |> Enum.concat(
          racers
          |> Map.values()
          |> Enum.filter(fn r ->
            !Enum.find(socket.assigns.qualifying, &(&1.nickname == r.nickname))
          end)
          |> Enum.map(fn r ->
            %Racer{
              id: "external-#{r.external_racer_id}",
              nickname: r.nickname,
              photo: r.photo,
              average_lap: r.average_lap,
              fastest_lap: r.fastest_lap,
              kart_num: r.kart_num,
              position: r.position,
              external_racer_id: r.external_racer_id,
              laps: r.laps,
              racer_profile_id: r.racer_profile_id
            }
          end)
        )
        |> Enum.sort_by(& &1.fastest_lap)
        |> Enum.with_index()
        |> Enum.map(fn {racer, index} -> %Racer{racer | position: index + 1} end)
      else
        socket.assigns.qualifying
      end

    currently_racing =
      racers
      |> Map.values()
      |> Enum.map(& &1.nickname)
      |> MapSet.new()

    {
      :noreply,
      socket
      |> assign(:currently_racing, currently_racing)
      |> assign(:qualifying, qualifying)
    }
  end

  def handle_info(msg, socket) do
    Logger.debug("Undefined handle_info for messge: #{inspect(msg, pretty: true)}")
    {:noreply, socket}
  end

  defp apply_action(socket, :show, _) do
    races = Races.league_races_on_date(socket.assigns.date)

    Listener.subscribe(socket.assigns.location)

    socket
    |> assign(:page_title, "League Races for #{socket.assigns.date}")
    |> assign(:races, races)
    |> assign(:currently_racing, MapSet.new())
    |> assign(:qualifying, calculate_qualifying(races))
  end

  defp apply_action(socket, :season, %{"race_id" => race_id}) do
    admin_redirect(socket) do
      races = Races.league_races_on_date(socket.assigns.date)

      socket
      |> assign(:page_title, "Select Season Race")
      |> assign(:races, Races.league_races_on_date(socket.assigns.date))
      |> assign(:seasons, Races.list_seasons())
      |> assign(:race, Races.get_race!(race_id))
      |> assign(:qualifying, calculate_qualifying(races))
    end
  end

  def calculate_qualifying(races, standing \\ %{})

  def calculate_qualifying([], standing) do
    standing
    |> Map.values()
    |> Enum.sort_by(& &1.fastest_lap)
    |> Enum.with_index()
    |> Enum.map(fn {racer, index} -> %Racer{racer | position: index + 1} end)
  end

  def calculate_qualifying([%Race{} = race | races], standing) do
    standing =
      if Race.is_qualifying_race?(race) do
        race.racers
        |> Enum.reduce(standing, &calculate_qualifying_for_racer(&1, &2))
      else
        standing
      end

    calculate_qualifying(races, standing)
  end

  def calculate_qualifying_for_racer(racer, standing) do
    Map.update(standing, racer.nickname, racer, fn val ->
      if val && val.fastest_lap && racer && racer.fastest_lap do
        cond do
          racer.fastest_lap > val.fastest_lap -> val
          racer.fastest_lap < val.fastest_lap -> racer
          true -> racer
        end
      else
        # No comparison can be made since fastest_lap data isn't available for both
        racer
      end
    end)
  end
end
