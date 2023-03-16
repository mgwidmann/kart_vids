defmodule KartVidsWeb.LocationLive.Racing do
  use KartVidsWeb, :live_view
  require Logger

  alias KartVids.Content
  alias KartVids.Races.Listener
  alias KartVids.Races.ListenerSupervisor
  alias KartVids.Races.ListenerSupervisor.Status, as: ListenerStatus
  alias KartVids.Races.Listener.Racer
  alias Phoenix.LiveView.JS

  embed_templates "racing/*"

  @check_timeout 10_000
  @large_number 9_999_999_999.0
  @lap_number "lap_number"
  @amb_time "amb_time"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  @spec handle_params(map(), any, Phoenix.LiveView.Socket.t()) :: {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_params(%{"location_id" => id}, _, socket) do
    location = socket.assigns[:location] || Content.get_location!(id)
    Listener.subscribe(location)

    Process.send_after(self(), :check_listener, @check_timeout)

    {
      :noreply,
      socket
      |> assign(:page_title, "Racing: #{location.name}")
      |> assign(:location, location)
      |> assign(:listener_status, ListenerSupervisor.listener_status(location))
      |> assign(:fastest_speed_level, nil)
      |> assign(:speed_level, nil)
      |> assign(:racers, nil)
      |> assign(:racer_change, nil)
      |> assign(:race_state, nil)
      |> assign(:race_name, nil)
      |> assign(:race_type, nil)
      |> assign(:first_amb, 0.0)
      |> assign(:scoreboard, nil)
      |> assign(:win_by, nil)
    }
  end

  @impl true
  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) :: {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("change_race_type", %{"race_type" => %{"race_type" => race_type_string}}, socket) when race_type_string in ["laptime", "position"] do
    {
      :noreply,
      socket
      |> assign(:race_type, String.to_existing_atom(race_type_string))
    }
  end

  @impl true
  @spec handle_info(Phoenix.Socket.Broadcast.t(), Phoenix.LiveView.Socket.t()) :: {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info(
        %Phoenix.Socket.Broadcast{event: event, payload: %KartVids.Races.Listener.State{racers: racers, fastest_speed_level: fastest_speed_level, speed_level: speed_level, race_name: race_name, scoreboard: scoreboard, win_by: win_by}},
        socket
      )
      when event in ["race_data", "race_completed"] and win_by in ["laptime", "position"] do
    race_state = String.to_existing_atom(event)
    win_by = String.to_existing_atom(win_by)

    race_type = race_type(socket.assigns.race_type, win_by, socket.assigns.race_state, String.to_existing_atom(event))
    sorted_racers = racers |> Map.values() |> sort_racers(race_type)

    position_change =
      if socket.assigns.race_type == race_type do
        compute_position_change(sorted_racers, socket.assigns.racers, socket.assigns.racer_change)
      else
        # If race_type changed this broadcast, we are not tracking poistion change correctly so just clear it out
        %{}
      end

    {
      :noreply,
      socket
      |> assign(:race_state, race_state)
      |> assign(:race_name, race_name)
      |> assign(:scoreboard, scoreboard)
      |> assign(:fastest_speed_level, fastest_speed_level)
      |> assign(:speed_level, speed_level)
      |> assign(:racers, sorted_racers)
      |> assign(:race_type, race_type)
      |> assign(:win_by, win_by)
      |> assign(:racer_change, position_change)
    }
  end

  def handle_info(:check_listener, socket) do
    Process.send_after(self(), :check_listener, @check_timeout)

    {
      :noreply,
      socket
      |> assign(:listener_status, ListenerSupervisor.listener_status(socket.assigns.location))
    }
  end

  def handle_info(msg, socket) do
    Logger.debug("Undefined handle_info for messge: #{inspect(msg, pretty: true)}")
    {:noreply, socket}
  end

  @typep race_type() :: :laptime | :position

  @spec race_type(nil | race_type(), race_type(), :race_completed | :race_data, :race_completed | :race_data) :: race_type()
  # With race_type setting and race is restarting
  def race_type(race_type, win_by, :race_completed, :race_data) when not is_nil(race_type), do: race_type(nil, win_by, :race_completed, :race_data)

  # Without race_type setting use default as the broadcasted type
  def race_type(nil, win_by, _, _) do
    win_by
  end

  # Otherwise just use what was already selected
  def race_type(race_type, _race_name, _old_race_state, _new_race_state), do: race_type

  @spec compute_position_change(list(Racer.t()), list(Racer.t()), %{pos_integer() => integer()}) :: %{pos_integer() => integer()}
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

  @spec sort_racers(list(Racer.t()), race_type()) :: list(Racer.t())
  def sort_racers(racers, :position) do
    sort_racers_by_position(racers)
  end

  def sort_racers(racers, :laptime) do
    sort_racers_by_best_lap(racers)
  end

  defp sort_racers_by_position(racers) do
    racers
    |> Enum.sort_by(
      fn
        %Racer{laps: []} ->
          {0, 0}

        %Racer{laps: laps} ->
          last_lap = List.last(laps)

          {lap_num, ""} =
            last_lap
            |> Map.get(@lap_number)
            |> Integer.parse()

          amb_time = Map.get(last_lap, @amb_time)
          # Largest lap time with smallest amb_time
          # Tuple comparison will allow this to be compared with just > and <
          # i.e. P2 is on lap 5 with amb time of 100 seconds whereas P1 is on lap 6 with amb time of 110 seconds (amb time is much larger in reality)
          # {5, -100} < {6, -110}
          # true, the 6th lap is ahead with more laps completed, but when the P2 passes the finish line
          # {6, -120} < {6, -110}
          # P1 is still ahead
          {lap_num, -amb_time}
      end,
      :desc
    )
    |> Stream.with_index()
    # Reassign position value
    |> Enum.map(fn {racer, index} -> %Racer{racer | position: index + 1} end)
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

  def lap_count(%Racer{laps: []}), do: 0

  def lap_count(%Racer{laps: laps}) do
    last_lap = List.last(laps)
    {lap, ""} = last_lap |> Map.get(@lap_number) |> Integer.parse()

    # 0 indexed lap counting
    lap + 1
  end

  def racer_row_add_remove(racer) do
    JS.transition("scaleInOut", to: "#scoreboard-#{racer.external_racer_id}")
  end

  def scoreboard_result(scoreboard, position) do
    Enum.find(scoreboard, fn {_kart, score} -> score[:position] == position end)
  end

  def scoreboard_racer(nil, _), do: nil

  def scoreboard_racer({kart, _score}, racers) do
    {kart_num, ""} = Integer.parse(kart)
    Enum.find(racers, &(&1.kart_num == kart_num))
  end

  def gap(%Racer{laps: [_, _ | _] = laps}, [%Racer{laps: [_, _ | _] = leader_laps} | _], :position) do
    last_leader_lap = List.last(leader_laps) |> Map.get("amb_time")
    last_lap = List.last(laps) |> Map.get("amb_time")
    format_lap(abs(last_leader_lap - last_lap), true)
  end

  def gap(%Racer{fastest_lap: fastest_lap}, [%Racer{fastest_lap: leader_fastest_lap} | _], :laptime) when not is_nil(fastest_lap) and not is_nil(leader_fastest_lap) do
    format_lap(fastest_lap - leader_fastest_lap, true)
  end

  def gap(_, _, _) do
    # Output ...
    format_lap(0.0)
  end
end
