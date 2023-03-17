defmodule KartVids.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KartVids.Content` context.
  """

  @doc """
  Generate a video.
  """
  def video_fixture(attrs \\ %{}) do
    {:ok, video} =
      attrs
      |> Enum.into(%{
        description: "some description",
        duration_seconds: 42,
        location: "some location",
        name: "some name",
        recorded_on: ~U[2022-10-28 02:49:00Z],
        size_mb: 120.5
      })
      |> KartVids.Content.create_video()

    video
  end

  @doc """
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        name: "Autobahn Speedway Dulles",
        street: "45448 E Severn Way #150",
        street_2: nil,
        city: "Sterling",
        state: "VA",
        country: "USA",
        code: "20166",
        adult_kart_min: 1,
        adult_kart_max: 29,
        junior_kart_min: 30,
        junior_kart_max: 60,
        timezone: "America/New_York",
        image_url: "https://autobahnspeed.com/wp-content/themes/autobahn/assets/images/logos/new/redwhite.svg",
        websocket_url: "ws://autobahn-livescore.herokuapp.com/?track=1&location=aisdulles",
        min_lap_time: 15.0,
        max_lap_time: 25.0
      })

    {:ok, location} = KartVids.Content.create_location(:system, attrs)

    location
  end
end
