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
    case Races.list_racer_profile_by_nickname(nickname) do
      [racer_profile | others] ->
        if Enum.empty?(others) do
          {:noreply,
           socket
           |> push_navigate(to: ~p"/locations/#{location_id}/racers/#{racer_profile.id}")}
        else
          location = Content.get_location!(location_id)
          racers = [racer_profile | others]

          {:noreply,
           socket
           |> assign(:location_id, location_id)
           |> assign(:location, location)
           |> assign(:racers, racers)}
        end

      [] ->
        {:noreply, socket |> put_flash(:error, "The user \"#{nickname}\" cannot be found.") |> push_redirect(to: ~p"/locations/#{location_id}/racing")}
    end
  end
end
