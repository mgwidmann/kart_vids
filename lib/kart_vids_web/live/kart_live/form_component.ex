defmodule KartVidsWeb.KartLive.FormComponent do
  use KartVidsWeb, :live_component

  alias KartVids.Races

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage kart records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="kart-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :location_id}} type="hidden" />
        <.input field={{f, :kart_num}} type="number" label="Kart Number" />
        <.input field={{f, :fastest_lap_time}} type="number" label="Fastest Lap Time Ever" step="any" />
        <.input field={{f, :average_fastest_lap_time}} type="number" label="Average Fastest Lap Time in One Race" step="any" />
        <.input field={{f, :number_of_races}} type="number" label="Number of Races" />
        <.input field={{f, :average_rpms}} type="number" label="Average RPMs" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Kart</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{kart: kart} = assigns, socket) do
    changeset = Races.change_kart(kart)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"kart" => kart_params}, socket) do
    changeset =
      socket.assigns.kart
      |> Races.change_kart(kart_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"kart" => kart_params}, socket) do
    save_kart(socket, socket.assigns.action, kart_params)
  end

  defp save_kart(socket, :edit, kart_params) do
    case Races.update_kart(socket.assigns.kart, kart_params) do
      {:ok, _kart} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kart updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_kart(socket, :new, kart_params) do
    case Races.create_kart(kart_params) do
      {:ok, _kart} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kart created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
