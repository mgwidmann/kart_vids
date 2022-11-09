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
     |> assign(:race_data, nil)
     |> assign(:listener_alive?, !is_nil(listener) && Process.alive?(listener))}
  end

  @impl true
  @spec handle_info(Phoenix.Socket.Broadcast.t(), Phoenix.LiveView.Socket.t()) :: {:noreply, map}
  def handle_info(%Phoenix.Socket.Broadcast{event: "race_data", payload: %KartVids.Races.Listener.State{} = race_data}, socket) do
    {:noreply,
     socket
     |> assign(:race_data, race_data)}
  end

  def handle_info(:check_listener, socket) do
    listener = Listener.whereis(socket.assigns.location)
    Process.send_after(self(), :check_listener, @check_timeout)

    {:noreply,
     socket
     |> assign(:listener, listener)
     |> assign(:listener_alive?, !is_nil(listener) && Process.alive?(listener))}
  end
end
