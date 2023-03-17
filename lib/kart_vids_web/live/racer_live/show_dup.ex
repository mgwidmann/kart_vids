defmodule KartVidsWeb.RacerLive.ShowDup do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Races

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id, "nickname" => nickname, "search" => "true"} = params, _url, socket) do
    query_params = Map.drop(params, ["location_id", "nickname", "search"])

    case Races.autocomplete_racer_nickname(nickname, 100) do
      # At least two matches
      [{_nickname, id, _photo}, another | others] ->
        racers = Races.get_racer_profiles!([id | Enum.map([another | others], &elem(&1, 1))])
        show_dups(socket, racers, location_id, query_params)

      [{_nickname, id, _photo}] ->
        navigate_directly(socket, id, location_id, query_params)

      [] ->
        cannot_be_found_friendly(socket, nickname, location_id)
    end
  end

  def handle_params(%{"location_id" => location_id, "external_racer_id" => external_racer_id} = params, _url, socket) do
    racer_profile = Races.get_racer_profile_by_attrs(%{external_racer_id: external_racer_id})

    if racer_profile do
      navigate_directly(socket, racer_profile.id, location_id, Map.drop(params, ["location_id", "external_racer_id"]))
    else
      cannot_be_found(socket, external_racer_id, location_id)
    end
  end

  def handle_params(%{"location_id" => location_id, "nickname" => nickname} = params, _url, socket) do
    query_params = Map.drop(params, ["location_id", "nickname"])

    case Races.list_racer_profile_by_nickname(nickname) do
      [racer_profile | others] ->
        if Enum.empty?(others) do
          navigate_directly(socket, racer_profile.id, location_id, query_params)
        else
          show_dups(socket, [racer_profile | others], location_id, query_params)
        end

      [] ->
        cannot_be_found_friendly(socket, nickname, location_id)
    end
  end

  defp show_dups(socket, racers, location_id, query_params) do
    location = socket.assigns[:location] || Content.get_location!(location_id)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:location, location)
      |> assign(:racers, racers)
      |> assign(:query_params, query_params)
      |> assign(:search, nil)
    }
  end

  defp navigate_directly(socket, id, location_id, query_params) do
    {
      :noreply,
      socket
      |> push_navigate(to: ~p"/locations/#{location_id}/racers/#{id}?#{query_params}")
    }
  end

  defp cannot_be_found_friendly(socket, identifier, location_id) do
    location = socket.assigns[:location] || Content.get_location!(location_id)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:location, location)
      |> assign(:racers, [])
      |> assign(:query_params, nil)
      |> assign(:search, identifier)
    }
  end

  defp cannot_be_found(socket, nickname, location_id) do
    {:noreply, socket |> put_flash(:error, "The user \"#{nickname}\" cannot be found.") |> push_redirect(to: ~p"/locations/#{location_id}/racing")}
  end
end
