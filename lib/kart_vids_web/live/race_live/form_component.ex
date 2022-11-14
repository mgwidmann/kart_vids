defmodule KartVidsWeb.RaceLive.FormComponent do
  use KartVidsWeb, :live_component

  alias KartVids.Races

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage race records in your database.</:subtitle>
      </.header>

      <.simple_form :let={f} for={@changeset} id="race-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={{f, :location_id}} type="hidden" />
        <.input field={{f, :external_race_id}} type="text" label="external_race_id" />
        <.input field={{f, :name}} type="text" label="name" />
        <.input field={{f, :started_at}} type="datetime-local" label="started_at" />
        <.input field={{f, :ended_at}} type="datetime-local" label="ended_at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Race</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{race: race} = assigns, socket) do
    changeset = Races.change_race(race)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"race" => race_params}, socket) do
    changeset =
      socket.assigns.race
      |> Races.change_race(race_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"race" => race_params}, socket) do
    save_race(socket, socket.assigns.action, race_params)
  end

  defp save_race(socket, :edit, race_params) do
    case Races.update_race(socket.assigns.race, race_params) do
      {:ok, _race} ->
        {:noreply,
         socket
         |> put_flash(:info, "Race updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_race(socket, :new, race_params) do
    case Races.create_race(race_params) do
      {:ok, _race} ->
        {:noreply,
         socket
         |> put_flash(:info, "Race created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
