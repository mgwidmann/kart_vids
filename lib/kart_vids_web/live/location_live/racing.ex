defmodule KartVidsWeb.LocationLive.Racing do
  use KartVidsWeb, :live_view
  require Logger

  alias KartVids.Content
  alias KartVids.Races.Listener
  alias KartVids.Races.Listener.Racer
  alias Phoenix.LiveView.JS

  embed_templates "racing/*"

  @check_timeout 10_000

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    location = Content.get_location!(id)
    listener = Listener.whereis(location)
    Listener.subscribe(location)

    Process.send_after(self(), :check_listener, @check_timeout)

    {:noreply,
     socket
     |> assign(:page_title, "Racing: #{location.name}")
     |> assign(:location, location)
     |> assign(:listener, listener)
     |> assign(:fastest_speed_level, nil)
     |> assign(:speed_level, nil)
     |> assign(:racers, nil)
     |> assign(:racer_change, nil)
     |> assign(:race_state, nil)
     |> assign(:race_name, nil)
     |> assign(:scoreboard, nil)
     |> assign(:listener_alive?, !is_nil(listener) && Process.alive?(listener))}
  end

  @impl true
  @spec handle_info(Phoenix.Socket.Broadcast.t(), Phoenix.LiveView.Socket.t()) :: {:noreply, map}
  def handle_info(%Phoenix.Socket.Broadcast{event: event, payload: %KartVids.Races.Listener.State{racers: racers, fastest_speed_level: fastest_speed_level, speed_level: speed_level, race_name: race_name, scoreboard: scoreboard}}, socket)
      when event in ["race_data", "race_completed"] do
    sorted_racers = racers |> Map.values() |> sort_racers(race_name)

    position_change = compute_position_change(sorted_racers, socket.assigns.racers, socket.assigns.racer_change)

    {
      :noreply,
      socket
      |> assign(:race_state, String.to_existing_atom(event))
      |> assign(:race_name, race_name)
      |> assign(:scoreboard, scoreboard)
      |> assign(:fastest_speed_level, fastest_speed_level)
      |> assign(:speed_level, speed_level)
      |> assign(:racers, sorted_racers)
      |> assign(:racer_change, position_change)
    }
  end

  def handle_info(:check_listener, socket) do
    listener = Listener.whereis(socket.assigns.location)
    Process.send_after(self(), :check_listener, @check_timeout)

    {:noreply,
     socket
     |> assign(:listener, listener)
     |> assign(:listener_alive?, !is_nil(listener) && Process.alive?(listener))}
  end

  def handle_info(msg, socket) do
    Logger.debug("Undefined handle_info for messge: #{inspect(msg, pretty: true)}")
    {:noreply, socket}
  end

  def compute_position_change(new_racers, previous_racers, last_position_change) when is_list(new_racers) and is_list(previous_racers) and is_map(last_position_change) do
    for {racer, racer_pos} <- Enum.with_index(new_racers), {prev_racer, prev_racer_pos} <- Enum.with_index(previous_racers), racer.kart_num == prev_racer.kart_num, into: %{} do
      if prev_racer_pos - racer_pos == 0 do
        {racer.kart_num, last_position_change[racer.kart_num]}
      else
        {racer.kart_num, prev_racer_pos - racer_pos}
      end
    end
  end

  def compute_position_change(new_racers, _, _) do
    new_racers
    |> Enum.map(&{&1.kart_num, 0})
    |> Enum.into(%{})
  end

  def sort_racers(racers, nil) do
    sort_racers_by_best_lap(racers)
  end

  def sort_racers(racers, race_name) do
    if race_name |> String.downcase() |> String.contains?(["aekc race"]) do
      sort_racers_by_position(racers)
    else
      sort_racers_by_best_lap(racers)
    end
  end

  @large_number 9_999_999_999.0
  defp sort_racers_by_position(racers) do
    Enum.sort_by(racers, fn %Racer{laps: laps} ->
      # When there are no laps yet, use default of a large but equal number
      List.last(laps, %{"amb_time" => @large_number}) |> Map.get("amb_time")
    end)
  end

  defp sort_racers_by_best_lap(racers) do
    Enum.sort_by(racers, fn
      %Racer{fastest_lap: nil} -> @large_number
      %Racer{fastest_lap: fastest_lap} -> fastest_lap
    end)
  end

  defp race_state(:race_data), do: "Race in progress"
  defp race_state(:race_completed), do: "Race Completed!"
  defp race_state(nil), do: nil

  @no_data "..."

  def amb_time([]), do: @no_data

  def amb_time([_ | _] = laps) do
    laps
    |> Enum.reverse()
    |> hd()
    |> Map.get("amb_time", 999.99)
    |> Kernel./(1)
    |> Decimal.from_float()
    |> Decimal.round(3)
    |> Decimal.to_float()
    |> Number.Delimit.number_to_delimited(delimiter: ",", separator: ".")
  end

  def racer_row_add_remove(racer) do
    JS.transition("scaleInOut", to: "#scoreboard-#{racer.nickname}")
  end

  def speed_string(1), do: "Fastest"
  def speed_string(2), do: "Slow"
  def speed_string(number), do: "Slower (#{number})"

  def scoreboard_result(scoreboard, position) do
    Enum.find(scoreboard, fn {_kart, score} -> score[:position] == position end)
  end

  def scoreboard_racer(nil, _), do: nil

  def scoreboard_racer({kart, _score}, racers) do
    {kart_num, ""} = Integer.parse(kart)
    Enum.find(racers, &(&1.kart_num == kart_num))
  end
end
