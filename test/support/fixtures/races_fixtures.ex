defmodule KartVids.RacesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KartVids.Races` context.
  """

  @doc """
  Generate a kart.
  """
  def kart_fixture(attrs \\ %{}) do
    {:ok, kart} =
      attrs
      |> Enum.into(%{
        average_fastest_lap_time: 120.5,
        average_rpms: 42,
        fasest_lap_time: 120.5,
        kart_num: "some kart_num",
        number_of_races: 42
      })
      |> KartVids.Races.create_kart()

    kart
  end
end
