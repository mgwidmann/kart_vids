defmodule KartVidsWeb.SeasonLive.RaceFormComponent do
  use KartVidsWeb, :live_component

  alias KartVids.Races
  import KartVids.SeasonLive.Helper

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle></:subtitle>
      </.header>

      <.simple_form :let={f} for={@form} as={:assign_season} id="season-race-form" phx-target={@myself} phx-submit="save">
        <.input field={{f, :location_id}} type="hidden" />
        <.input field={{f, :race_id}} type="hidden" />
        <.input field={{f, :season}} type="select" label="Season" options={@seasons |> Enum.map(&{season_name(&1), &1.id})} />
        <:actions>
          <.button phx-disable-with="Saving...">Assign</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:form, %{"location_id" => assigns.race.location_id, "race_id" => assigns.race.id})
    }
  end

  @impl true
  def handle_event("save", %{"assign_season" => %{"location_id" => _location_id, "race_id" => race_id, "season" => season_id}}, socket) when season_id != "" and race_id != "" and season_id != "" do
    save_race_to_season(socket, race_id, season_id)
  end

  defp save_race_to_season(socket, race_id, season_id) do
    admin_redirect(socket) do
      season = Races.get_season!(season_id)
      racers = Races.list_racers(race_id)
      race = Races.get_race!(race_id)

      {:ok, _race} = Races.update_race(socket.assigns.current_user, race, %{season_id: season_id})

      for racer <- racers do
        Races.create_season_racer(season, racer.racer_profile_id)
      end

      {
        :noreply,
        socket
        |> put_flash(:info, "Racers added to season successfully")
        |> push_navigate(to: socket.assigns.navigate)
      }
    else
      {:noreply, socket}
    end
  end
end
