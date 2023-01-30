defmodule KartVidsWeb.LocationLive.Index do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Content.Location

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :locations, list_locations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    admin_redirect(socket) do
      socket
      |> assign(:page_title, "Edit Location")
      |> assign(:location, Content.get_location!(id))
    end
  end

  defp apply_action(socket, :new, _params) do
    admin_redirect(socket) do
      socket
      |> assign(:page_title, "New Location")
      |> assign(:location, %Location{})
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Locations")
    |> assign(:location, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    admin_redirect(socket) do
      location = Content.get_location!(id)
      {:ok, _} = Content.delete_location(location)

      {:noreply, assign(socket, :locations, list_locations())}
    else
      {:noreply, socket}
    end
  end

  defp list_locations do
    Content.list_locations()
  end
end
