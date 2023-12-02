defmodule KartVidsWeb.LeaderboardLive.Index do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Content.Location
  alias KartVids.Races

  embed_templates("../racer_live/racer/*")
  embed_templates("./most_races/*")

  @top_records 25
  @default_days 90

  @impl true
  def mount(params, _session, socket) do
    type = String.to_existing_atom(params["type"] || "fastest_lap")
    after_date = Date.from_iso8601!(params["after"] || Date.utc_today() |> Date.add(-@default_days) |> Date.to_iso8601())
    tab = String.to_existing_atom(params["tab"] || "adult")

    {
      :ok,
      socket
      |> assign(:type, type)
      |> assign(:tab, tab)
      |> assign(:after_date, after_date)
      |> assign(:quick_date, unless(params["after"], do: 90))
    }
  end

  @impl true
  def handle_params(%{"location_id" => id}, _, socket) do
    location = socket.assigns[:location] || Content.get_location!(id)

    {
      :noreply,
      socket
      |> assign(:page_title, "Leaderboard")
      |> assign(:location_id, id)
      |> assign(:location, location)
      |> assign(:adult_racers, list_racers(socket.assigns.type, :adult, socket.assigns.after_date, location))
      |> assign(:junior_racers, list_racers(socket.assigns.type, :junior, socket.assigns.after_date, location))
    }
  end

  @impl true
  def handle_event("change_type", %{"leaderboard_type" => %{"type" => "fastest_lap"}}, socket) do
    {
      :noreply,
      socket
      |> assign(:type, :fastest_lap)
      |> push_navigate(to: ~p"/locations/#{socket.assigns.location}/leaderboard?type=#{socket.assigns.type}&tab=#{socket.assigns.tab}&after=#{Date.to_iso8601(socket.assigns.after_date)}")
    }
  end

  def handle_event("change_type", %{"leaderboard_type" => %{"type" => "most_races"}}, socket) do
    {
      :noreply,
      socket
      |> assign(:type, :most_races)
      |> push_navigate(to: ~p"/locations/#{socket.assigns.location}/leaderboard?type=#{socket.assigns.type}&tab=#{socket.assigns.tab}&after=#{Date.to_iso8601(socket.assigns.after_date)}")
    }
  end

  def handle_event("date-change", %{"after_date" => %{"date" => date}}, socket) do
    socket = assign(socket, :after_date, Date.from_iso8601!(date))

    {
      :noreply,
      socket
      |> assign(:adult_racers, list_racers(socket.assigns.type, :adult, socket.assigns.after_date, socket.assigns.location))
      |> assign(:junior_racers, list_racers(socket.assigns.type, :junior, socket.assigns.after_date, socket.assigns.location))
      |> push_patch(to: ~p"/locations/#{socket.assigns.location}/leaderboard?type=#{socket.assigns.type}&tab=#{socket.assigns.tab}&after=#{Date.to_iso8601(socket.assigns.after_date)}")
    }
  end

  def handle_event("search", %{"after_date" => %{"quick" => quick_days_str}}, socket) do
    {num_days, ""} = Integer.parse(quick_days_str)

    socket =
      socket
      |> assign(:after_date, Date.utc_today() |> Date.add(-num_days))
      |> assign(:quick_date, num_days)

    {
      :noreply,
      socket
      |> assign(:adult_racers, list_racers(socket.assigns.type, :adult, socket.assigns.after_date, socket.assigns.location))
      |> assign(:junior_racers, list_racers(socket.assigns.type, :junior, socket.assigns.after_date, socket.assigns.location))
      |> push_patch(to: ~p"/locations/#{socket.assigns.location}/leaderboard?type=#{socket.assigns.type}&tab=#{socket.assigns.tab}&after=#{Date.to_iso8601(socket.assigns.after_date)}")
    }
  end

  def handle_event("disqualify", %{"id" => racer_id, "for" => "fastest_lap"}, socket) do
    Races.disqualify!(racer_id, :fastest_lap)

    {
      :noreply,
      socket
      |> assign(:adult_racers, list_racers(socket.assigns.type, :adult, socket.assigns.after_date, socket.assigns.location))
      |> assign(:junior_racers, list_racers(socket.assigns.type, :junior, socket.assigns.after_date, socket.assigns.location))
      |> push_patch(to: ~p"/locations/#{socket.assigns.location}/leaderboard?type=#{socket.assigns.type}&tab=#{socket.assigns.tab}&after=#{Date.to_iso8601(socket.assigns.after_date)}")
    }
  end

  def list_racers(:fastest_lap, adult_junior, after_date, location) do
    Races.fastest_lap(location, adult_junior, after_date, @top_records)
  end

  def list_racers(:most_races, adult_junior, after_date, location) do
    Races.most_races(location, adult_junior, after_date, @top_records)
  end

  def location_begin_days_ago(%Phoenix.Socket{assigns: %{location: %Location{} = location}}) do
    location_begin_days_ago(location)
  end

  def location_begin_days_ago(%Location{inserted_at: inserted_at}) do
    Date.utc_today()
    |> Date.diff(NaiveDateTime.to_date(inserted_at))
  end

  defp quick_select_options(%Location{adult_kart_reset_on: adult_kart_reset_on, junior_kart_reset_on: junior_kart_reset_on} = location) do
    [
      "Last Week": 7,
      "Last 2 Weeks": 14,
      "Last Month": 30,
      "90 days": 90,
      "6 months": 182,
      Year: 365,
      YTD: Date.utc_today() |> Date.day_of_year(),
      "All Time": location_begin_days_ago(location)
    ]
    |> Kernel.++("Adult Kart Reset": if(adult_kart_reset_on, do: Date.diff(Date.utc_today(), adult_kart_reset_on)))
    |> Kernel.++("Junior Kart Reset": if(junior_kart_reset_on, do: Date.diff(Date.utc_today(), junior_kart_reset_on)))
    |> Enum.filter(fn {_k, v} -> v end)
    |> Enum.sort_by(fn {_k, v} -> v end)
  end

  defp quick_select_value(%Location{} = location, after_date) do
    options = quick_select_options(location) |> Keyword.values()

    days = Date.diff(Date.utc_today(), after_date)

    quick_select_value_enumerate(options, days, options)
  end

  defp quick_select_value_enumerate(_, days, options) when days <= 7, do: List.first(options)
  defp quick_select_value_enumerate([], _days, options), do: List.last(options)
  defp quick_select_value_enumerate([i], days, options) when days >= i, do: List.last(options)
  defp quick_select_value_enumerate([i, j | _rest], days, _options) when days >= i and days < j, do: i
  defp quick_select_value_enumerate([_i | rest], days, options), do: quick_select_value_enumerate(rest, days, options)
end
