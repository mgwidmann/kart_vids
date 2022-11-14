defmodule KartVidsWeb.RaceLive.Index do
  use KartVidsWeb, :live_view

  alias KartVids.Races
  alias KartVids.Races.Race

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id} = params, _url, socket) do
    {
      :noreply,
      socket
      |> assign(:races, list_races(location_id))
      |> assign(:location_id, location_id)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Race")
    |> assign(:race, Races.get_race!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Race")
    |> assign(:race, %Race{location_id: socket.assigns.location_id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Races")
    |> assign(:race, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    race = Races.get_race!(id)
    {:ok, _} = Races.delete_race(race)

    {:noreply, assign(socket, :races, list_races(socket.assigns.location_id))}
  end

  defp list_races(location_id) do
    Races.list_races(location_id)
  end
end
