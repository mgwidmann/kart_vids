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
        fastest_lap_time: 120.5,
        kart_num: "some kart_num",
        number_of_races: 42
      })
      |> KartVids.Races.create_kart()

    kart
  end

  @doc """
  Generate a race.
  """
  def race_fixture(attrs \\ %{}) do
    {:ok, race} =
      attrs
      |> Enum.into(%{
        ended_at: ~U[2022-11-13 03:06:00Z],
        external_race_id: "some external_race_id",
        name: "some name",
        started_at: ~U[2022-11-13 03:06:00Z]
      })
      |> KartVids.Races.create_race()

    race
  end

  @doc """
  Generate a racer.
  """
  def racer_fixture(attrs \\ %{}) do
    {:ok, racer} =
      attrs
      |> Enum.into(%{
        average_lap: 120.5,
        fastest_lap: 120.5,
        kart_num: 42,
        nickname: "some nickname",
        photo: "some photo",
        position: 42
      })
      |> KartVids.Races.create_racer()

    racer
  end
end
