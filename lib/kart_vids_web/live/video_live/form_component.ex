defmodule KartVidsWeb.VideoLive.FormComponent do
  use KartVidsWeb, :live_component

  alias KartVids.Content
  alias KartVids.Content.Video

  @impl true
  def mount(socket) do
    locations = Content.list_locations()

    {
      :ok,
      socket
      |> assign(:locations, locations)
      |> allow_upload(:video, accept: ~w(.mp4 .mov), max_entries: 1, external: &KartVidsWeb.VideoLive.Index.presign_upload/2, max_file_size: Video.maximum_size_bytes())
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Select a video and begin uploading!</:subtitle>
      </.header>

      <.simple_form :let={f} for={@changeset} id="video-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class={if(@upload_present?, do: "hidden", else: "")}>
          <.drop_video>
            <.live_file_input upload={@uploads.video} />
          </.drop_video>
        </div>
        <%= if @upload_present? do %>
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
        <% end %>
        <%= for err <- upload_errors(@uploads.video) do %>
          <p class="alert alert-danger"><%= error_to_string(err) %></p>
        <% end %>

        <.input field={{f, :s3_path}} type="hidden" />
        <.input field={{f, :duration_seconds}} type="hidden" data-phx-hook="VideoHook" />
        <.input field={{f, :location_id}} type="select" options={@locations |> Enum.map(&{&1.name, &1.id})} />
        <.input field={{f, :size}} type="hidden" />
        <.input field={{f, :name}} type="text" label="Name" data-phx-hook="VideoHook" />
        <.input field={{f, :description}} type="textarea" label="Description" />
        <.input field={{f, :recorded_on}} type="datetime-local" label="Recorded on" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Video</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def drop_video(assigns) do
    ~H"""
    <section class="bg-slate-100 border-dashed border-slate-700 border-2 rounded-[5.0rem] mt-8 px-8">
      <div class="grid max-w-screen-xl px-0 py-8 mx-auto lg:gap-8 xl:gap-0 lg:py-16 lg:grid-cols-12">
        <div class="mr-auto place-self-center lg:col-span-7">
          <p class="max-w-2xl mb-6 font-light text-gray-500 lg:mb-8 md:text-lg lg:text-xl">
            <h3 class="max-w-2xl mb-4 text-md font-extrabold tracking-tight leading-none md:text-lg xl:text-xl">
              Drop video here or click
            </h3>
            <%= render_slot(@inner_block) %>
          </p>
        </div>
        <div class="hidden lg:mt-0 lg:col-span-5 lg:flex">
          <img src={~p"/images/KartVids-640.png"} />
        </div>
      </div>
    </section>
    """
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files"

  @impl true
  def update(%{video: video} = assigns, socket) do
    video = video || %Video{}

    {video, upload_present} =
      if assigns.uploads.video.entries != [] do
        {set_defaults(video, assigns.uploads.video.entries, assigns.current_user), true}
      else
        {video, false}
      end

    changeset = Content.change_video(video)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:video, video)
     |> assign(:upload_present?, upload_present)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"video" => video_params}, socket) do
    changeset =
      socket.assigns.video
      |> set_defaults(socket.assigns.uploads.video.entries, socket.assigns.current_user)
      |> Content.change_video(video_params |> clean_params())
      |> Map.put(:action, :validate)

    {
      :noreply,
      socket
      |> assign(:upload_present?, length(socket.assigns.uploads.video.entries) > 0)
      |> assign(:changeset, changeset)
    }
  end

  def handle_event("save", %{"video" => video_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :video, fn %{path: path}, entry ->
        IO.puts("Path uploaded was: #{inspect(path)} for entry: #{inspect(entry)}")
      end)

    IO.puts("Uploaded files: #{inspect(uploaded_files)}")
    save_video(socket, socket.assigns.action, video_params |> clean_params())
  end

  def clean_params(params) do
    params
    |> Enum.reject(fn
      {_, v} when v in [nil, ""] -> true
      _ -> false
    end)
    |> Map.new()
  end

  def set_defaults(%Video{name: name} = video, [%{client_name: client_name} | _] = entry, current_user) when name in [nil, ""] and client_name not in [nil, ""] do
    %{video | name: client_name} |> set_defaults(entry, current_user)
  end

  def set_defaults(%Video{recorded_on: recorded} = video, [%{client_last_modified: last_modified} | _] = entry, current_user) when recorded in [nil, ""] and last_modified not in [nil, ""] do
    %{video | recorded_on: last_modified |> DateTime.from_unix!(:millisecond)} |> set_defaults(entry, current_user)
  end

  def set_defaults(%Video{size: size} = video, [%{client_size: client_size} | _] = entry, current_user) when size in [nil, 0, ""] and client_size not in [nil, 0, ""] do
    %{video | size: client_size} |> set_defaults(entry, current_user)
  end

  def set_defaults(%Video{mime_type: mime_type} = video, [%{client_type: client_type} | _] = entry, current_user) when mime_type in [nil, ""] and client_type not in [nil, ""] do
    %{video | mime_type: client_type} |> set_defaults(entry, current_user)
  end

  def set_defaults(%Video{s3_path: path} = video, [%{uuid: uuid, client_type: client_type} | _] = entry, current_user) when path in [nil, ""] and client_type not in [nil, ""] do
    [ext | _] = MIME.extensions(client_type)
    %{video | s3_path: Path.join(Content.user_originals_storage_prefix(current_user), "#{uuid}.#{ext}")} |> set_defaults(entry, current_user)
  end

  def set_defaults(%Video{} = video, _, _), do: video

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
    case Content.create_video(socket.assigns.current_user, video_params) do
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
