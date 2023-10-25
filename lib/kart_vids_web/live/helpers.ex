defmodule KartVidsWeb.Live.Helpers do
  @moduledoc """
  Static function helpers for rendering live pages
  """

  @no_data "···"

  def format_lap(lap, small_allowed \\ false)

  def format_lap(nil, _), do: @no_data
  def format_lap(lap, false) when lap < 10.0, do: @no_data

  def format_lap(lap, _) do
    lap
    |> Kernel./(1)
    |> Decimal.from_float()
    |> Decimal.round(3)
  end

  def date_format(date) do
    date
    |> Calendar.strftime("%B %d, %Y")
  end

  def time_format(time) do
    time
    |> Calendar.strftime("%I:%M %p")
  end
end
