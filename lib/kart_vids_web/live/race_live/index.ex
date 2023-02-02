defmodule KartVidsWeb.RaceLive.Index do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Races
  alias KartVids.Races.Race

  embed_templates("races/*")

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id} = params, _url, socket) do
    location = Content.get_location!(location_id)

    {
      :noreply,
      socket
      |> assign(:races, list_races(location_id))
      |> assign(:location_id, location_id)
      |> assign(:location, location)
      |> assign(:racer_autocomplete, [])
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    admin_redirect(socket) do
      socket
      |> assign(:page_title, "Edit Race")
      |> assign(:race, Races.get_race!(id))
    end
  end

  defp apply_action(socket, :new, _params) do
    admin_redirect(socket) do
      socket
      |> assign(:page_title, "New Race")
      |> assign(:race, %Race{location_id: socket.assigns.location_id})
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Races")
    |> assign(:race, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    admin_redirect(socket) do
      race = Races.get_race!(id)
      {:ok, _} = Races.delete_race(socket.assigns.current_user, race)

      {:noreply, assign(socket, :races, list_races(socket.assigns.location_id))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("search", %{"find_user" => %{"nickname" => ""}}, socket) do
    {:noreply, assign(socket, :racer_autocomplete, [])}
  end

  def handle_event("search", %{"find_user" => %{"nickname" => nickname}}, socket) do
    racers = Races.autocomplete_racer_nickname(nickname)

    {:noreply, assign(socket, :racer_autocomplete, racers)}
  end

  defp list_races(location_id) do
    Races.list_races(location_id)
  end
end
