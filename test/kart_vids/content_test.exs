defmodule KartVids.ContentTest do
  use KartVids.DataCase

  alias KartVids.Content

  describe "videos" do
    alias KartVids.Content.Video

    import KartVids.ContentFixtures

    @invalid_attrs %{
      description: nil,
      duration_seconds: nil,
      location: nil,
      name: nil,
      recorded_on: nil,
      size_mb: nil
    }

    test "list_videos/0 returns all videos" do
      video = video_fixture()
      assert Content.list_videos() == [video]
    end

    test "get_video!/1 returns the video with given id" do
      video = video_fixture()
      assert Content.get_video!(video.id) == video
    end

    test "create_video/1 with valid data creates a video" do
      valid_attrs = %{
        description: "some description",
        duration_seconds: 42,
        location: "some location",
        name: "some name",
        recorded_on: ~U[2022-10-28 02:49:00Z],
        size_mb: 120.5
      }

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

      update_attrs = %{
        description: "some updated description",
        duration_seconds: 43,
        location: "some updated location",
        name: "some updated name",
        recorded_on: ~U[2022-10-29 02:49:00Z],
        size_mb: 456.7
      }

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

  describe "locations" do
    alias KartVids.Content.Location

    import KartVids.ContentFixtures

    @invalid_attrs %{
      city: nil,
      code: nil,
      country: nil,
      name: nil,
      state: nil,
      street: nil,
      street_2: nil
    }

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Content.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Content.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      valid_attrs = %{
        city: "some city",
        code: "some code",
        country: "some country",
        name: "some name",
        state: "some state",
        street: "some street",
        street_2: "some street_2"
      }

      assert {:ok, %Location{} = location} = Content.create_location(valid_attrs)
      assert location.city == "some city"
      assert location.code == "some code"
      assert location.country == "some country"
      assert location.name == "some name"
      assert location.state == "some state"
      assert location.street == "some street"
      assert location.street_2 == "some street_2"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()

      update_attrs = %{
        city: "some updated city",
        code: "some updated code",
        country: "some updated country",
        name: "some updated name",
        state: "some updated state",
        street: "some updated street",
        street_2: "some updated street_2"
      }

      assert {:ok, %Location{} = location} = Content.update_location(location, update_attrs)
      assert location.city == "some updated city"
      assert location.code == "some updated code"
      assert location.country == "some updated country"
      assert location.name == "some updated name"
      assert location.state == "some updated state"
      assert location.street == "some updated street"
      assert location.street_2 == "some updated street_2"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_location(location, @invalid_attrs)
      assert location == Content.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Content.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Content.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Content.change_location(location)
    end
  end
end
