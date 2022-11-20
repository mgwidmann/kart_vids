defmodule KartVidsWeb.RaceLive.League do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Races
  alias KartVids.Races.{Race, Racer}

  embed_templates "races/*"
  embed_templates "../racer_live/racer/*"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "date" => date} = params, _url, socket) do
    location = Content.get_location!(location_id)
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

  defp apply_action(socket, :show, _) do
    races = Races.league_races_on_date(socket.assigns.date)

    socket
    |> assign(:page_title, "League Races for #{socket.assigns.date}")
    |> assign(:races, races)
    |> assign(:qualifying, calculate_qualifying(races))
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
      cond do
        val && racer.fastest_lap > val.fastest_lap -> val
        val && racer.fastest_lap < val.fastest_lap -> racer
        true -> racer
      end
    end)
  end
end
