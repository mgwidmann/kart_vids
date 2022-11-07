defmodule KartVidsWeb.KartLive.Index do
  use KartVidsWeb, :live_view

  alias KartVids.Races
  alias KartVids.Races.Kart

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :karts, list_karts())}
  end

  @impl true
  def handle_params(%{"location_id" => location_id} = params, _url, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params) |> assign(:location_id, location_id)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Kart")
    |> assign(:kart, Races.get_kart!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Kart")
    |> assign(:kart, %Kart{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Karts")
    |> assign(:kart, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    kart = Races.get_kart!(id)
    {:ok, _} = Races.delete_kart(kart)

    {:noreply, assign(socket, :karts, list_karts())}
  end

  defp list_karts do
    Races.list_karts()
  end
end
