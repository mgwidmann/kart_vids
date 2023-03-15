defmodule KartVidsWeb.Content do
  use KartVidsWeb, :verified_routes

  alias KartVids.Content

  def on_mount(:location_id, %{"location_id" => location_id}, _session, socket) do
    {
      :cont,
      Phoenix.Component.assign_new(socket, :location, fn ->
        Content.get_location!(location_id)
      end)
    }
  end
end
