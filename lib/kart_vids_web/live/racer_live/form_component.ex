defmodule KartVidsWeb.RacerLive.FormComponent do
  use KartVidsWeb, :live_component

  alias KartVids.Races

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage racer records in your database.</:subtitle>
      </.header>

      <.simple_form :let={f} for={@changeset} id="racer-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={{f, :race_id}} type="hidden" />
        <.input field={{f, :nickname}} type="text" label="nickname" />
        <.input field={{f, :photo}} type="text" label="photo" />
        <.input field={{f, :kart_num}} type="number" label="kart_num" />
        <.input field={{f, :fastest_lap}} type="number" label="fastest_lap" step="any" />
        <.input field={{f, :average_lap}} type="number" label="average_lap" step="any" />
        <.input field={{f, :position}} type="number" label="position" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Racer</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{racer: racer} = assigns, socket) do
    changeset = Races.change_racer(racer)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"racer" => racer_params}, socket) do
    changeset =
      socket.assigns.racer
      |> Races.change_racer(racer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"racer" => racer_params}, socket) do
    save_racer(socket, socket.assigns.action, racer_params)
  end

  defp save_racer(socket, :edit, racer_params) do
    admin_redirect(socket) do
      case Races.update_racer(socket.assigns.current_user, socket.assigns.racer, racer_params) do
        {:ok, _racer} ->
          {:noreply,
           socket
           |> put_flash(:info, "Racer updated successfully")
           |> push_navigate(to: socket.assigns.navigate)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  defp save_racer(socket, :new, racer_params) do
    admin_redirect(socket) do
      case Races.create_racer(socket.assigns.current_user, racer_params) do
        {:ok, _racer} ->
          {:noreply,
           socket
           |> put_flash(:info, "Racer created successfully")
           |> push_navigate(to: socket.assigns.navigate)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, socket}
    end
  end
end
