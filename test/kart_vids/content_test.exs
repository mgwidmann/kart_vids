defmodule KartVids.ContentTest do
  use KartVids.DataCase

  alias KartVids.Content

  describe "videos" do
    alias KartVids.Content.Video

    import KartVids.ContentFixtures

    @invalid_attrs %{description: nil, duration_seconds: nil, location: nil, name: nil, recorded_on: nil, size_mb: nil}

    test "list_videos/0 returns all videos" do
      video = video_fixture()
      assert Content.list_videos() == [video]
    end

    test "get_video!/1 returns the video with given id" do
      video = video_fixture()
      assert Content.get_video!(video.id) == video
    end

    test "create_video/1 with valid data creates a video" do
      valid_attrs = %{description: "some description", duration_seconds: 42, location: "some location", name: "some name", recorded_on: ~U[2022-10-28 02:49:00Z], size_mb: 120.5}

      assert {:ok, %Video{} = video} = Content.create_video(valid_attrs)
      assert video.description == "some description"
      assert video.duration_seconds == 42
      assert video.location == "some location"
      assert video.name == "some name"
      assert video.recorded_on == ~U[2022-10-28 02:49:00Z]
      assert video.size_mb == 120.5
    end

    test "create_video/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_video(@invalid_attrs)
    end

    test "update_video/2 with valid data updates the video" do
      video = video_fixture()
      update_attrs = %{description: "some updated description", duration_seconds: 43, location: "some updated location", name: "some updated name", recorded_on: ~U[2022-10-29 02:49:00Z], size_mb: 456.7}

      assert {:ok, %Video{} = video} = Content.update_video(video, update_attrs)
      assert video.description == "some updated description"
      assert video.duration_seconds == 43
      assert video.location == "some updated location"
      assert video.name == "some updated name"
      assert video.recorded_on == ~U[2022-10-29 02:49:00Z]
      assert video.size_mb == 456.7
    end

    test "update_video/2 with invalid data returns error changeset" do
      video = video_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_video(video, @invalid_attrs)
      assert video == Content.get_video!(video.id)
    end

    test "delete_video/1 deletes the video" do
      video = video_fixture()
      assert {:ok, %Video{}} = Content.delete_video(video)
      assert_raise Ecto.NoResultsError, fn -> Content.get_video!(video.id) end
    end

    test "change_video/1 returns a video changeset" do
      video = video_fixture()
      assert %Ecto.Changeset{} = Content.change_video(video)
    end
  end
end
