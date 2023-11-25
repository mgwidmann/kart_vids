defmodule KartVidsWeb.KartLive.Show do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Races
  alias KartVids.Karts

  embed_templates("../racer_live/racer/*")

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params = %{"location_id" => location_id}, _, socket) do
    location = socket.assigns.location || Content.get_location!(location_id)
    kart = get_kart(params)

    [fastest_racer | top_records] = list_fastest(kart, location)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:location, location)
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:kart, kart)
      |> assign(:fastest_racer, fastest_racer)
      |> assign(:top_records, top_records)
    }
  end

  @impl true
  def handle_event("disqualify", %{"id" => racer_id, "for" => "fastest_lap"}, socket) do
    Races.disqualify!(racer_id, :fastest_lap)

    [fastest_racer | top_records] = list_fastest(socket.assigns.kart, socket.assigns.location)

    {:ok, kart} = Races.update_kart(:system, socket.assigns.kart, %{"fastest_lap_time" => fastest_racer.fastest_lap, "fastest_racer_id" => fastest_racer.id})

    {
      :noreply,
      socket
      |> assign(:kart, kart)
      |> assign(:fastest_racer, fastest_racer)
      |> assign(:top_records, top_records)
    }
  end

  def list_fastest(kart, location) do
    Karts.fastest_races(kart, location)
  end

  defp page_title(:show), do: "Show Kart"
  defp page_title(:edit), do: "Edit Kart"

  defp get_kart(%{"id" => id}), do: Races.get_kart!(id) |> Races.kart_with_fastest_racer()
  defp get_kart(%{"location_id" => location_id, "kart_number" => kart_number}), do: Races.find_kart_by_location_and_number(location_id, kart_number) |> Races.kart_with_fastest_racer()
end
