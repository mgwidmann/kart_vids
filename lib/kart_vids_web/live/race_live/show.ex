defmodule KartVidsWeb.RaceLive.Show do
  use KartVidsWeb, :live_view

  require Logger
  alias KartVids.Races
  alias KartVids.Races.Racer
  alias KartVids.Content

  embed_templates "../racer_live/racer/*"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "id" => id}, _, socket) do
    location = socket.assigns[:location] || Content.get_location!(location_id)
    racers = Races.list_racers(id)

    racers =
      case racers do
        [first | _] ->
          reorder(racers, first.win_by)

        [] ->
          []
      end

    kart_nums = Enum.map(racers, & &1.kart_num)

    {
      :noreply,
      socket
      |> assign(:location, location)
      |> assign(:location_id, location_id)
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:race_id, id)
      |> assign(:race, Races.get_race!(id))
      |> assign(:racers, racers)
      |> assign(:karts, get_karts(kart_nums, location.id))
    }
  end

  defp page_title(:show), do: "Show Race"
  defp page_title(:edit), do: "Edit Race"

  def get_karts(kart_nums, location_id) when is_list(kart_nums) do
    Races.get_karts(location_id, kart_nums)
    # Sort so slowest numbers are first
    |> Enum.sort_by(& &1.fastest_lap_time, :desc)
  end

  def reorder(racers, :laptime) do
    racers
  end

  def reorder(racers, :position) do
    racers
    |> Enum.sort_by(fn %Racer{laps: laps, position: position} ->
      # If no laps, use position as amb_time
      (List.last(laps) || %{amb_time: position}).amb_time
    end)
    |> Stream.with_index(1)
    |> Enum.map(fn {racer, position} ->
      %Racer{racer | position: position}
    end)
  end

  def reorder(racers, other) do
    Logger.warning("Unexpected function call: #{__MODULE__}.reorder(racers, #{inspect(other)}); racers[0] = #{Enum.at(racers, 0) |> inspect()}")
    reorder(racers, :laptime)
  end
end
