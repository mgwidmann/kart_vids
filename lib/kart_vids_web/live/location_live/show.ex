defmodule KartVidsWeb.LocationLive.Show do
  use KartVidsWeb, :live_view

  alias KartVids.Content

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:location, socket.assigns[:location] || Content.get_location!(id))}
  end

  defp page_title(:show), do: "Show Location"
  defp page_title(:edit), do: "Edit Location"
end
