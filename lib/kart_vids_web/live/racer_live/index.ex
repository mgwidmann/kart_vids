defmodule KartVidsWeb.RacerLive.Index do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Races
  alias KartVids.Races.Racer

  embed_templates "racer/*"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "race_id" => race_id} = params, _url, socket) do
    location = Content.get_location!(location_id)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:location, location)
      |> assign(:race_id, race_id)
      |> assign(:racers, list_racers(race_id))
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    admin_redirect(socket) do
      socket
      |> assign(:page_title, "Edit Racer")
      |> assign(:racer, Races.get_racer!(id))
    end
  end

  defp apply_action(socket, :new, _params) do
    admin_redirect(socket) do
      socket
      |> assign(:page_title, "New Racer")
      |> assign(:racer, %Racer{race_id: socket.assigns.race_id})
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Racers")
    |> assign(:racer, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    admin_redirect(socket) do
      racer = Races.get_racer!(id)
      {:ok, _} = Races.delete_racer(racer)

      {:noreply, assign(socket, :racers, list_racers(socket.assigns.race_id))}
    else
      {:noreply, socket}
    end
  end

  defp list_racers(race_id) do
    race_id
    |> Races.list_racers()
  end
end
