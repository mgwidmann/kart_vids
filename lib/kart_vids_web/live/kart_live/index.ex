defmodule KartVidsWeb.KartLive.Index do
  use KartVidsWeb, :live_view

  alias KartVids.Races
  alias KartVids.Races.Kart

  embed_templates("./karts/**")

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"location_id" => location_id} = params, _url, socket) do
    location_id
    |> Races.all_karts_topic_name()
    |> KartVidsWeb.Endpoint.subscribe()

    tab = params["tab"] || "adult"
    sort_by = params["sort"] || "kart-num"
    sort_dir = String.to_existing_atom(params["dir"] || "asc")

    {
      :noreply,
      socket
      |> assign(:location_id, location_id)
      |> apply_action(socket.assigns.live_action, params)
      |> assign(:karts, list_karts(location_id))
      |> assign(:tab, tab)
      |> assign(:sort_by, sort_by)
      |> assign(:sort_dir, sort_dir)
      |> assign(:best_karts, Races.get_racer_profile_best_karts_count(location_id))
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    admin_redirect(socket) do
      socket
      |> assign(:page_title, "Edit Kart")
      |> assign(:kart, Races.get_kart!(id))
    end
  end

  defp apply_action(socket, :new, _params) do
    admin_redirect(socket) do
      socket
      |> assign(:page_title, "New Kart")
      |> assign(:kart, %Kart{location_id: socket.assigns.location_id})
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Karts")
    |> assign(:kart, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    admin_redirect(socket) do
      kart = Races.get_kart!(id)
      {:ok, _} = Races.delete_kart(socket.assigns.current_user, kart)

      {:noreply, assign(socket, :karts, list_karts(socket.assigns.location_id))}
    else
      {:noreply, socket}
    end
  end

  defp list_karts(location_id) do
    Races.list_karts(location_id)
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "update", payload: %KartVids.Races.Kart{} = kart},
        socket
      ) do
    karts =
      [kart | socket.assigns.karts |> Enum.filter(&(&1.id != kart.id))]
      |> Enum.sort_by(& &1.kart_num)

    {:noreply,
     socket
     |> assign(:karts, karts)}
  end
end
