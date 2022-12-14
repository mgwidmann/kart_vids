defmodule KartVidsWeb.RaceLive.Show do
  use KartVidsWeb, :live_view

  alias KartVids.Races
  alias KartVids.Content

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "id" => id}, _, socket) do
    location = Content.get_location!(location_id)

    {:noreply,
     socket
     |> assign(:location, location)
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:race, Races.get_race!(id))}
  end

  defp page_title(:show), do: "Show Race"
  defp page_title(:edit), do: "Edit Race"
end
