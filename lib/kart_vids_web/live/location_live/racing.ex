defmodule KartVidsWeb.LocationLive.Racing do
  use KartVidsWeb, :live_view
  require Logger

  alias KartVids.Content
  alias KartVids.Races.Listener
  alias KartVids.Races.Listener.Racer

  embed_templates "racing/*"

  @check_timeout 10_000

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    location = Content.get_location!(id)
    listener = Listener.whereis(location)
    Listener.subscribe(location)

    Process.send_after(self(), :check_listener, @check_timeout)

    {:noreply,
     socket
     |> assign(:page_title, "Racing: #{location.name}")
     |> assign(:location, location)
     |> assign(:listener, listener)
     |> assign(:racers, nil)
     |> assign(:race_state, nil)
     |> assign(:race_name, nil)
     |> assign(:scoreboard, nil)
     |> assign(:listener_alive?, !is_nil(listener) && Process.alive?(listener))}
  end

  @impl true
  @spec handle_info(Phoenix.Socket.Broadcast.t(), Phoenix.LiveView.Socket.t()) :: {:noreply, map}
  def handle_info(%Phoenix.Socket.Broadcast{event: event, payload: %KartVids.Races.Listener.State{racers: racers, race_name: race_name, scoreboard: scoreboard}}, socket) when event in ["race_data", "race_completed"] do
    {:noreply,
     socket
     |> assign(:race_state, String.to_existing_atom(event))
     |> assign(:race_name, race_name)
     |> assign(:scoreboard, scoreboard)
     |> assign(:racers, racers |> Map.values() |> sort_racers(race_name))}
  end

  def handle_info(:check_listener, socket) do
    listener = Listener.whereis(socket.assigns.location)
    Process.send_after(self(), :check_listener, @check_timeout)

    {:noreply,
     socket
     |> assign(:listener, listener)
     |> assign(:listener_alive?, !is_nil(listener) && Process.alive?(listener))}
  end

  def handle_info(msg, socket) do
    Logger.debug("Undefined handle_info for messge: #{inspect(msg, pretty: true)}")
    {:noreply, socket}
  end

  def sort_racers(racers, nil) do
    sort_racers_by_position(racers)
  end

  def sort_racers(racers, race_name) do
    if race_name |> String.downcase() |> String.contains?(["aekc race"]) do
      Enum.sort_by(racers, fn
        %Racer{laps: [_ | _] = laps} ->
          %{"amb_time" => amb_time} = Enum.reverse(laps) |> hd()
          -amb_time

        %Racer{laps: []} ->
          sort_racers_by_position(racers)
      end)
    else
      sort_racers_by_position(racers)
    end
  end

  defp sort_racers_by_position(racers) do
    Enum.sort_by(racers, & &1.position)
  end

  defp race_state(:race_data), do: "Race in progress"
  defp race_state(:race_completed), do: "Race Completed!"
  defp race_state(nil), do: nil

  @no_data "..."

  def amb_time([]), do: @no_data

  def amb_time([_ | _] = laps) do
    laps
    |> Enum.reverse()
    |> hd()
    |> Map.get("amb_time", 999.99)
    |> Kernel./(1)
    |> Decimal.from_float()
    |> Decimal.round(3)
    |> Decimal.to_float()
    |> Number.Delimit.number_to_delimited(delimiter: ",", separator: ".")
  end

  def scoreboard_result(scoreboard, position) do
    Enum.find(scoreboard, fn {_kart, score} -> score[:position] == position end)
  end

  def scoreboard_racer(nil, _), do: nil

  def scoreboard_racer({kart, _score}, racers) do
    {kart_num, ""} = Integer.parse(kart)
    Enum.find(racers, &(&1.kart_num == kart_num))
  end
end
