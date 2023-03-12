defmodule KartVidsWeb.KartLive.Show do
  use KartVidsWeb, :live_view

  alias KartVids.Races

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params = %{"location_id" => location_id}, _, socket) do
    kart = get_kart(params)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:kart, kart)
      |> assign(:fastest_racer, Races.get_racer_fastest_kart(kart))
    }
  end

  defp page_title(:show), do: "Show Kart"
  defp page_title(:edit), do: "Edit Kart"

  defp get_kart(%{"id" => id}), do: Races.get_kart!(id)
  defp get_kart(%{"location_id" => location_id, "kart_number" => kart_number}), do: Races.find_kart_by_location_and_number(location_id, kart_number)
end
