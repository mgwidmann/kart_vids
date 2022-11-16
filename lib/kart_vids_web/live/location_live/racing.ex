defmodule KartVidsWeb.LocationLive.Racing do
  use KartVidsWeb, :live_view
  require Logger

  alias KartVids.Content
  alias KartVids.Races.Listener

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
     |> assign(:listener_alive?, !is_nil(listener) && Process.alive?(listener))}
  end

  @impl true
  @spec handle_info(Phoenix.Socket.Broadcast.t(), Phoenix.LiveView.Socket.t()) :: {:noreply, map}
  def handle_info(%Phoenix.Socket.Broadcast{event: event, payload: %KartVids.Races.Listener.State{racers: racers, race_name: race_name}}, socket) when event in ["race_data", "race_completed"] do
    {:noreply,
     socket
     |> assign(:race_state, String.to_existing_atom(event))
     |> assign(:race_name, race_name)
     |> assign(:racers, racers |> Map.values() |> sort_racers())}
  end

  def handle_info(:check_listener, socket) do
    listener = Listener.whereis(socket.assigns.location)
    Process.send_after(self(), :check_listener, @check_timeout)

    {:noreply,
     socket
     |> assign(:listener, listener)
     |> assign(:listener_alive?, !is_nil(listener) && Process.alive?(listener))}
  end

  def sort_racers(racers) do
    Enum.sort_by(racers, & &1.position)
  end

  defp race_state(:race_data), do: "Race in progress"
  defp race_state(:race_completed), do: "Race Completed!"
  defp race_state(nil), do: nil
end
