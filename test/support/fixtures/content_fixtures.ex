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
end
