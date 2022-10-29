defmodule KartVidsWeb.VideoLive.FormComponent do
  use KartVidsWeb, :live_component

  alias KartVids.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage video records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="video-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :location}} type="text" label="location" />
        <.input field={{f, :duration_seconds}} type="number" label="duration_seconds" />
        <.input field={{f, :size_mb}} type="number" label="size_mb" step="any" />
        <.input field={{f, :name}} type="text" label="name" />
        <.input field={{f, :description}} type="text" label="description" />
        <.input field={{f, :recorded_on}} type="datetime-local" label="recorded_on" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Video</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{video: video} = assigns, socket) do
    changeset = Content.change_video(video)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"video" => video_params}, socket) do
    changeset =
      socket.assigns.video
      |> Content.change_video(video_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"video" => video_params}, socket) do
    save_video(socket, socket.assigns.action, video_params)
  end

  defp save_video(socket, :edit, video_params) do
    case Content.update_video(socket.assigns.video, video_params) do
      {:ok, _video} ->
        {:noreply,
         socket
         |> put_flash(:info, "Video updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_video(socket, :new, video_params) do
    case Content.create_video(video_params) do
      {:ok, _video} ->
        {:noreply,
         socket
         |> put_flash(:info, "Video created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
