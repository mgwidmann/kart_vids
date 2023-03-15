defmodule KartVidsWeb.LocationLive.FormComponent do
  use KartVidsWeb, :live_component

  alias KartVids.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage location records in your database.</:subtitle>
      </.header>

      <.simple_form :let={f} for={@changeset} id="location-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={{f, :name}} type="text" label="Name" />
        <.input field={{f, :street}} type="text" label="Street" />
        <.input field={{f, :street_2}} type="text" label="Street Line 2 (optional)" />
        <.input field={{f, :city}} type="text" label="City" />
        <.input field={{f, :state}} type="text" label="State/Province" />
        <.input field={{f, :code}} type="text" label="Zip/Postal Code" />
        <.input field={{f, :country}} type="text" label="Country" />
        <.input field={{f, :adult_kart_min}} type="number" label="First Adult Kart Number" />
        <.input field={{f, :adult_kart_max}} type="number" label="Last Adult Kart Number" />
        <.input field={{f, :junior_kart_min}} type="number" label="First Junior Kart Number" />
        <.input field={{f, :junior_kart_max}} type="number" label="Last Junior Kart Number" />
        <.input field={{f, :adult_kart_reset_on}} type="date" label="Adult Karts data reset on" />
        <.input field={{f, :junior_kart_reset_on}} type="date" label="Junior Karts data reset on" />
        <.input field={{f, :min_lap_time}} type="number" label="Minimum Possible Lap Time (for Kart statistics)" step="any" />
        <.input field={{f, :max_lap_time}} type="number" label="Maximum Possible Lap Time (for Kart statistics)" step="any" />
        <.input field={{f, :timezone}} type="select" label="Timezone" options={Tzdata.zone_lists_grouped() |> Enum.map(fn {region, list} -> {Atom.to_string(region) |> Phoenix.Naming.humanize(), list} end)} />
        <.input field={{f, :image_url}} type="text" label="Icon Image URL" />
        <.input field={{f, :websocket_url}} type="text" label="Websocket Connection URL" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Location</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{location: location} = assigns, socket) do
    changeset = Content.change_location(location)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset =
      socket.assigns.location
      |> Content.change_location(location_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"location" => location_params}, socket) do
    save_location(socket, socket.assigns.action, location_params)
  end

  defp save_location(socket, :edit, location_params) do
    admin_redirect(socket) do
      case Content.update_location(
             socket.assigns.current_user,
             socket.assigns.location,
             location_params
           ) do
        {:ok, _location} ->
          {:noreply,
           socket
           |> put_flash(:info, "Location updated successfully")
           |> push_navigate(to: socket.assigns.navigate)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  defp save_location(socket, :new, location_params) do
    admin_redirect(socket) do
      case Content.create_location(socket.assigns.current_user, location_params) do
        {:ok, _location} ->
          {:noreply,
           socket
           |> put_flash(:info, "Location created successfully")
           |> push_navigate(to: socket.assigns.navigate)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, socket}
    end
  end
end
