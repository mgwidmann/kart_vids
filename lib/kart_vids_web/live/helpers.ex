defmodule KartVidsWeb.Live.Helpers do
  @moduledoc """
  Static function helpers for rendering live pages
  """

  alias KartVids.Races.Kart

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

  def calculate_advantage(kart_num, [%Kart{} | _] = karts) do
    difference = kart_diff(kart_num, karts)

    if difference do
      "+#{format_lap(difference, true)}"
    end
  end

  defp kart_diff(kart_num, [slowest_kart = %Kart{} | _] = karts) do
    kart = Enum.find(karts, &(&1.kart_num == kart_num))

    if kart do
      Decimal.sub(Decimal.from_float(slowest_kart.fastest_lap_time), Decimal.from_float(kart.fastest_lap_time)) |> Decimal.to_float()
    end
  end

  def kart_advantage_color(kart_num, [%Kart{} | _] = karts) do
    difference = kart_diff(kart_num, karts)

    if difference do
      fastest_kart = List.last(karts)
      fastest_diff = kart_diff(fastest_kart.kart_num, karts)

      cond do
        fastest_diff == 0.0 || difference / fastest_diff >= 0.70 ->
          "text-green-500"

        difference / fastest_diff >= 0.30 ->
          "text-yellow-500"

        true ->
          "text-red-500"
      end
    end
  end
end
