defmodule KartVidsWeb.RacerLive.ShowDup do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Races

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "nickname" => nickname}, _url, socket) do
    [{_nickname, id} | others] = Races.autocomplete_racer_nickname(nickname)

    if Enum.empty?(others) do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/locations/#{location_id}/racers/#{id}")}
    else
      location = Content.get_location!(location_id)
      racers = Races.get_racer_profiles!([id | Enum.map(others, &elem(&1, 1))])

      {:noreply,
       socket
       |> assign(:location_id, location_id)
       |> assign(:location, location)
       |> assign(:racers, racers)}
    end
  end
end
