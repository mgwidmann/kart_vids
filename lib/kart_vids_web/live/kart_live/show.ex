defmodule KartVidsWeb.KartLive.Show do
  use KartVidsWeb, :live_view

  alias KartVids.Races

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "id" => id}, _, socket) do
    kart = Races.get_kart!(id)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:kart, kart)
      |> assign(:fastest_racer, Races.get_racer_fastest_kart(kart.kart_num))
    }
  end

  defp page_title(:show), do: "Show Kart"
  defp page_title(:edit), do: "Edit Kart"
end
