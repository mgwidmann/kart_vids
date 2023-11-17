defmodule KartVidsWeb.SeasonLive.FormComponent do
  use KartVidsWeb, :live_component

  alias KartVids.Races

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage season records in your database.</:subtitle>
      </.header>

      <.simple_form :let={f} for={@changeset} id="season-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={{f, :location_id}} type="hidden" />
        <.input field={{f, :season}} type="select" label="Season" options={KartVids.Races.Season.seasons() |> Keyword.keys()} />
        <.input field={{f, :start_at}} type="date" label="Start On" />
        <.input field={{f, :weekly_start_at}} type="time" label="Weekly Start Time" />
        <.input field={{f, :weekly_start_day}} type="select" label="Weekly Start Day" options={KartVids.Races.Season.weekly_start_days() |> Keyword.keys()} />
        <.input field={{f, :number_of_meetups}} type="number" label="Number of Meetups" />
        <.input field={{f, :daily_qualifiers}} type="number" label="Daily qualifiers" />
        <.input field={{f, :driver_type}} type="select" label="Driver Type" options={KartVids.Races.Season.driver_types() |> Keyword.keys()} />
        <.input field={{f, :daily_practice}} type="checkbox" label="Daily practice" />
        <.input field={{f, :position_qualifier}} type="checkbox" label="Position qualifier" />
        <.input field={{f, :ended}} type="checkbox" label="Ended" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Season</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{season: season} = assigns, socket) do
    changeset = Races.change_season(season)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"season" => season_params}, socket) do
    changeset =
      socket.assigns.season
      |> Races.change_season(season_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"season" => season_params}, socket) do
    save_season(socket, socket.assigns.action, season_params)
  end

  defp save_season(socket, :edit, season_params) do
    admin_redirect(socket) do
      case Races.update_season(socket.assigns.season, season_params) do
        {:ok, season} ->
          notify_parent({:saved, season})

          {:noreply,
           socket
           |> put_flash(:info, "Season updated successfully")
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  defp save_season(socket, :new, season_params) do
    admin_redirect(socket) do
      case Races.create_season(season_params) do
        {:ok, season} ->
          notify_parent({:saved, season})

          {:noreply,
           socket
           |> put_flash(:info, "Season created successfully")
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
