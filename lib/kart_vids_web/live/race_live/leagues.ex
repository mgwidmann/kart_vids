defmodule KartVidsWeb.RaceLive.Leagues do
  use KartVidsWeb, :live_view
  import KartVidsWeb.Components.Racing

  alias KartVids.Races

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id} = params, _url, socket) do
    leagues = Races.leagues()

    {
      :noreply,
      socket
      # |> assign(:races, list_races(location_id))
      |> assign(:location_id, location_id)
      |> assign(:leagues, leagues)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :index, _) do
    socket
    |> assign(:page_title, "League Races")
  end
end
