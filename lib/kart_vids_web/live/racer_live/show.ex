defmodule KartVidsWeb.RacerLive.Show do
  use KartVidsWeb, :live_view

  alias KartVids.Races

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "race_id" => race_id, "id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:location_id, location_id)
     |> assign(:race_id, race_id)
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:racer, Races.get_racer!(id))}
  end

  defp page_title(:show), do: "Show Racer"
  defp page_title(:edit), do: "Edit Racer"
end
