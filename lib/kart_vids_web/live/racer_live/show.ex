defmodule KartVidsWeb.RacerLive.Show do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Races
  alias KartVids.Races.Racer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"location_id" => location_id, "racer_profile_id" => racer_profile_id} = params,
        _url,
        socket
      ) do
    location = Content.get_location!(location_id)

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> assign(:location, location)
      |> assign(:racer_profile_id, racer_profile_id)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  @recent_hours 24

  defp apply_action(socket, :show, %{"racer_profile_id" => racer_profile_id}) do
    racer_profile = Races.get_racer_profile!(racer_profile_id)
    races = racer_profile.races |> Enum.sort_by(& &1.race.started_at, :desc)
    selected_race = races |> List.first()
    additional_assigns = select_race(selected_race)

    recent_timeframe = Timex.now() |> Timex.subtract(Timex.Duration.from_hours(@recent_hours))
    recent_best = races |> Enum.filter(&Timex.after?(&1.race.started_at, recent_timeframe)) |> Enum.min_by(& &1.fastest_lap, fn -> nil end)

    socket
    |> assign(:page_title, "#{racer_profile.nickname}'s Races")
    |> assign(:racer_profile, racer_profile)
    |> assign(:racer_races, races)
    |> assign(:selected_race, selected_race)
    |> assign(:recent_best, recent_best)
    |> assign(additional_assigns)
  end

  @impl true
  def handle_event("select_race", %{"race_id" => race_id}, socket) do
    selected_race = socket.assigns.racer_races |> Enum.find(&(&1.id == race_id))

    if selected_race do
      additional_assigns = select_race(selected_race)

      {
        :noreply,
        socket
        |> assign(:selected_race, selected_race)
        |> assign(additional_assigns)
      }
    else
      {:noreply, socket}
    end
  end

  def select_race(race) do
    laps = race |> Map.get(:laps) |> filter_laps()
    lap_averages = laps |> compute_averages()
    lap_average_map = lap_averages |> Enum.into(%{})
    laps = laps |> Enum.map(&Map.put_new(&1, :lap_average, lap_average_map[&1.lap_number]))

    %{laps: laps, lap_averages: lap_averages, laps_by_time: lap_times(laps)}
  end

  def get_photo([%Racer{photo: photo} | _]), do: photo

  def filter_laps([%{lap_time: 0.0, lap_number: 0} | laps]), do: laps
  def filter_laps(laps), do: laps

  def lap_times(laps) do
    laps
    |> Enum.map(&{&1.lap_number, &1.lap_time})
  end

  def compute_averages(nil), do: []
  def compute_averages([]), do: []

  def compute_averages(laps) do
    for lap <- laps do
      sublaps = laps |> Enum.filter(&(&1.lap_number <= lap.lap_number))
      count = length(sublaps)

      if count > 0 do
        sum = sublaps |> Enum.reduce(0, &(&1.lap_time + &2))
        {lap.lap_number, sum / count}
      else
        {lap.lap_number, lap.lap_time}
      end
    end
  end
end
