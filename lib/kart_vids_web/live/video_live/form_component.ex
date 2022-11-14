defmodule KartVidsWeb.VideoLive.FormComponent do
  use KartVidsWeb, :live_component

  alias KartVids.Content

  @impl true
  def render(assigns) do
    assigns = set_defaults(assigns)

    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage video records in your database.</:subtitle>
      </.header>

      <.simple_form :let={f} for={@changeset} id="video-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class="hidden">
          <.live_file_input upload={@uploads.video} />
        </div>
        <%= inspect(f) %>
        <%= for entry <- @uploads.video.entries do %>
          <article class="upload-entry">
            <figure>
              <.live_video_preview entry={entry} id="video-preview" />
              <figcaption><%= entry.client_name %></figcaption>
            </figure>

            <div class="grid grid-cols-12">
              <div class="col-span-11 flex items-center">
                <progress value={entry.progress} max="100" class="w-full"><%= entry.progress %>%</progress>
              </div>
              <div class="col-span-1 flex flex-col items-center align-middle">
                <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} aria-label="cancel">&times;</button>
              </div>
            </div>

            <%= for err <- upload_errors(@uploads.video, entry) do %>
              <p class="alert alert-danger"><%= error_to_string(err) %></p>
            <% end %>
          </article>
        <% end %>
        <%= for err <- upload_errors(@uploads.video) do %>
          <p class="alert alert-danger"><%= error_to_string(err) %></p>
        <% end %>

        <.input field={{f, :location_id}} type="hidden" />
        <.input field={{f, :s3_path}} type="hidden" />
        <.input field={{f, :duration_seconds}} type="hidden" data-phx-hook="VideoHook" />
        <.input field={{f, :size}} type="hidden" />
        <.input field={{f, :name}} type="text" label="Name" />
        <.input field={{f, :description}} type="textarea" label="Description" />
        <.input field={{f, :recorded_on}} type="datetime-local" label="Recorded on" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Video</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files"

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
    IO.inspect(video_params, label: "Validating changeset...")

    changeset =
      socket.assigns.video
      |> Content.change_video(video_params)
      |> Map.put(:action, :validate)

    IO.inspect(changeset, label: "Changeset:", pretty: true)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"video" => video_params}, socket) do
    save_video(socket, socket.assigns.action, video_params)
  end

  def set_defaults(%{uploads: %{video: %{entries: [%{client_name: client_name, client_size: client_size, client_type: client_type, client_last_modified: last_modified} | _]}}, changeset: changeset} = assigns) do
    if Ecto.Changeset.get_change(changeset, :name) == nil do
      client_name = String.replace(client_name, ~r/\.mp4|\.mov/, "")

      changeset =
        changeset
        |> Ecto.Changeset.put_change(:name, client_name)
        |> Ecto.Changeset.put_change(:size, client_size)
        |> Ecto.Changeset.put_change(:mime_type, client_type)
        |> Ecto.Changeset.put_change(:recorded_on, last_modified |> DateTime.from_unix!(:millisecond))

      %{assigns | changeset: changeset}
    else
      assigns
    end
  end

  # No video is loaded yet
  def set_defaults(assigns), do: assigns

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
