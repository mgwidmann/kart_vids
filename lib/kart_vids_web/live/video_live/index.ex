defmodule KartVidsWeb.VideoLive.Index do
  use KartVidsWeb, :live_view

  alias KartVids.Content
  alias KartVids.Content.Video

  @view_styles [:grid, :table]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:videos, list_videos())
     |> assign(:view, :grid)}
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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    video = Content.get_video!(id)
    {:ok, _} = Content.delete_video(video)

    {:noreply, assign(socket, :videos, list_videos())}
  end

  @view_style_strings @view_styles |> Enum.map(fn s -> Atom.to_string(s) end)
  def handle_event("view", %{"style" => view_style}, socket) when view_style in @view_style_strings do
    {:noreply,
     socket
     |> assign(:view, String.to_existing_atom(view_style))}
  end

  defp list_videos do
    Content.list_videos()
  end

  attr :class, :string

  defp button_group(assigns) do
    ~H"""
      <div class={@class}>
        <div class="inline-flex shadow-md hover:shadow-lg focus:shadow-lg" role="group">
          <button type="button" phx-click="view" phx-value-style="grid" class="rounded-l inline-block px-6 py-2.5 bg-sky-600 text-white font-medium text-xs leading-tight uppercase hover:bg-sky-700 focus:bg-sky-700 focus:outline-none focus:ring-0 active:bg-sky-800 transition duration-150 ease-in-out">Grid</button>
          <button type="button" phx-click="view" phx-value-style="table" class="rounded-r inline-block px-6 py-2.5 bg-sky-600 text-white font-medium text-xs leading-tight uppercase hover:bg-sky-700 focus:bg-sky-700 focus:outline-none focus:ring-0 active:bg-sky-800 transition duration-150 ease-in-out">Table</button>
        </div>
      </div>
    """
  end
end
