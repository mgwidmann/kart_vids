defmodule KartVidsWeb.VideoLive.Index do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Content.Video

  @view_styles [:grid, :table]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:videos, Content.list_videos(socket.assigns.current_user))
     |> assign(:view, :grid)
     |> allow_upload(:video, accept: ~w(.mp4 .mov), max_entries: 1, external: &presign_upload/2, max_file_size: Video.maximum_size_bytes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Video")
    |> assign(:video, Content.get_video!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Video")
    |> assign(:video, %Video{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Videos")
    |> assign(:video, nil)
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    video = Content.get_video!(id)
    {:ok, _} = Content.delete_video(video)

    {:noreply, assign(socket, :videos, Content.list_videos(socket.assigns.current_user))}
  end

  @view_style_strings @view_styles |> Enum.map(fn s -> Atom.to_string(s) end)
  def handle_event("view", %{"style" => view_style}, socket)
      when view_style in @view_style_strings do
    {:noreply,
     socket
     |> assign(:view, String.to_existing_atom(view_style))}
  end

  def handle_event("validate", _params, socket) do
    {
      :noreply,
      socket
      |> push_patch(to: ~p"/admin/videos/new")
    }
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :video, ref)}
  end

  def presign_upload(entry, socket) do
    config = %{
      region: Application.fetch_env!(:kart_vids, :aws_region),
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    user = socket.assigns.current_user
    user_hash = SimpleS3Upload.sha256(config[:secret_access_key], "#{user.email}/#{user.id}")

    uploads = socket.assigns.uploads
    bucket = Application.fetch_env!(:kart_vids, :videos_bucket_name)
    key = "videos/originals/#{user_hash}/#{entry.client_name}"

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(config, bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads[entry.upload_config].max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{uploader: "S3", key: key, url: "http://#{bucket}.s3-#{config.region}.amazonaws.com", fields: fields}
    {:ok, meta, socket}
  end

  attr :class, :string

  defp button_group(assigns) do
    ~H"""
    <div class={@class}>
      <div class="inline-flex shadow-md hover:shadow-lg focus:shadow-lg" role="group">
        <button
          type="button"
          phx-click="view"
          phx-value-style="grid"
          class="rounded-l inline-block px-6 py-2.5 bg-sky-600 text-white font-medium text-xs leading-tight uppercase hover:bg-sky-700 focus:bg-sky-700 focus:outline-none focus:ring-0 active:bg-sky-800 transition duration-150 ease-in-out"
        >
          Grid
        </button>
        <button
          type="button"
          phx-click="view"
          phx-value-style="table"
          class="rounded-r inline-block px-6 py-2.5 bg-sky-600 text-white font-medium text-xs leading-tight uppercase hover:bg-sky-700 focus:bg-sky-700 focus:outline-none focus:ring-0 active:bg-sky-800 transition duration-150 ease-in-out"
        >
          Table
        </button>
      </div>
    </div>
    """
  end
end
