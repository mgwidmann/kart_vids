defmodule KartVidsWeb.Components.Racing do
  @moduledoc """
  Common components used in Racing pages.
  """
  use Phoenix.Component

  attr(:league?, :boolean, default: false)
  attr(:league_type, :atom, values: KartVids.Races.Race.league_types() |> Keyword.keys())

  def league_string(assigns) do
    ~H"""
    <%= if @league? do %>
      <%= (@league_type || "yes") |> Phoenix.Naming.humanize() %>
    <% else %>
      No
    <% end %>
    """
  end
end
