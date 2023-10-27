defmodule KartVidsWeb.RaceLive.Index do
  use KartVidsWeb, :live_view
  import KartVidsWeb.Components.Racing

  alias KartVids.Content
  alias KartVids.Races
  alias KartVids.Races.Race
  import KartVids.SeasonLive.Helper

  embed_templates("races/*")

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id} = params, _url, socket) do
    location = Content.get_location!(location_id)

    date = Date.from_iso8601!(Map.get(params, "date", DateTime.utc_now() |> DateTime.shift_zone!(location.timezone) |> DateTime.to_date() |> Date.to_iso8601()))

    {
      :noreply,
      socket
      |> assign(:races, list_races(location, date))
      |> assign(:races_date, date)
      |> assign(:location_id, location_id)
      |> assign(:location, location)
      |> assign(:racer_autocomplete, [])
      |> assign(:selected, nil)
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

      {:noreply, assign(socket, :races, list_races(socket.assigns.location, socket.assigns.races_date))}
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

  def handle_event("select", %{"key" => "ArrowUp"}, socket) do
    {:noreply,
     assign(
       socket,
       :selected,
       select_racer(:up, socket.assigns.racer_autocomplete, socket.assigns.selected)
     )}
  end

  def handle_event("select", %{"key" => "ArrowDown"}, socket) do
    {
      :noreply,
      assign(socket, :selected, select_racer(:down, socket.assigns.racer_autocomplete, socket.assigns.selected))
    }
  end

  def handle_event("select", %{"key" => "Enter", "value" => search}, socket) do
    {
      :noreply,
      socket
      |> push_navigate(to: ~p"/locations/#{socket.assigns.location_id}/racers/by_nickname/#{search}?search=true")
    }
  end

  def handle_event("select", _, socket) do
    {:noreply, socket}
  end

  def handle_event("date-change", %{"find_user" => %{"date" => date}}, socket) do
    {
      :noreply,
      socket
      |> assign(:races, list_races(socket.assigns.location, Date.from_iso8601!(date)))
      |> push_navigate(to: ~p"/locations/#{socket.assigns.location_id}/races?date=#{date}")
    }
  end

  def select_racer(:up, racers, nil), do: List.last(racers) |> elem(1)
  def select_racer(:down, [{_racer, id} | _], nil), do: id
  def select_racer(_any_direction, [], nil), do: nil

  def select_racer(:up, racers, selected) when is_list(racers) and is_integer(selected) do
    selected_index = racers |> Enum.find_index(&match?({_, ^selected}, &1))
    racers_len = length(racers)

    cond do
      (selected_index && selected_index - 1 < 0) || selected_index == nil ->
        {_name, id} = Enum.at(racers, racers_len - 1)
        id

      selected_index != nil ->
        {_name, id} = Enum.at(racers, selected_index - 1)
        id
    end
  end

  def select_racer(:down, racers, selected) when is_list(racers) and is_integer(selected) do
    selected_index = racers |> Enum.find_index(&match?({_, ^selected}, &1))
    racers_len = length(racers)

    cond do
      (selected_index && selected_index + 1 >= racers_len) || selected_index == nil ->
        {_name, id} = Enum.at(racers, 0)
        id

      selected_index != nil ->
        {_name, id} = Enum.at(racers, selected_index + 1)
        id
    end
  end

  defp list_races(location, date) do
    location
    |> Races.list_races(date)
  end
end
