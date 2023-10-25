defmodule KartVidsWeb.SeasonLive.Index do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Races
  alias KartVids.Races.Season

  @impl true
  def mount(%{"active" => "false"}, _session, socket) do
    {
      :ok,
      socket
      |> assign(:active, false)
      |> assign(:seasons, Races.list_seasons(false))
    }
  end

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:active, true)
      |> assign(:seasons, Races.list_seasons(true))
    }
  end

  @impl true
  def handle_params(%{"location_id" => location_id} = params, _url, socket) do
    location = socket.assigns[:location] || Content.get_location!(location_id)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:location, location)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Season")
    |> assign(:season, Races.get_season!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Season")
    |> assign(:season, %Season{location_id: socket.assigns.location_id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Seasons")
    |> assign(:season, nil)
  end

  @impl true
  def handle_info({KartVidsWeb.SeasonLive.FormComponent, {:saved, season}}, socket) do
    {:noreply, assign(socket, :seasons, Races.list_seasons(!season.ended))}
  end

  @impl true
  def handle_event("change_active", %{"active" => %{"active" => "active"}}, socket) do
    {
      :noreply,
      socket
      |> assign(:active, true)
      |> assign(:seasons, Races.list_seasons(true))
      |> push_navigate(to: ~p"/admin/locations/#{socket.assigns.location_id}/seasons?active=true")
    }
  end

  def handle_event("change_active", %{"active" => %{"active" => "inactive"}}, socket) do
    {
      :noreply,
      socket
      |> assign(:active, false)
      |> assign(:seasons, Races.list_seasons(false))
      |> push_navigate(to: ~p"/admin/locations/#{socket.assigns.location_id}/seasons?active=false")
    }
  end

  def handle_event("delete", %{"id" => id}, socket) do
    season = Races.get_season!(id)
    {:ok, _} = Races.delete_season(season)

    {:noreply, assign(socket, :seasons, Races.list_seasons(socket.assigns.active))}
  end
end
