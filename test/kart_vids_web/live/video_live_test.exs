defmodule KartVidsWeb.VideoLiveTest do
  use KartVidsWeb.ConnCase

  import Phoenix.LiveViewTest
  import KartVids.AccountsFixtures
  import KartVids.ContentFixtures

  @create_attrs %{description: "some description", duration_seconds: 42, location: "some location", name: "some name", recorded_on: "2022-10-28T02:49:00Z", size_mb: 120.5}
  @update_attrs %{description: "some updated description", duration_seconds: 43, location: "some updated location", name: "some updated name", recorded_on: "2022-10-29T02:49:00Z", size_mb: 456.7}
  @invalid_attrs %{description: nil, duration_seconds: nil, location: nil, name: nil, recorded_on: nil, size_mb: nil}

  defp create_video(_) do
    video = video_fixture()
    %{video: video}
  end

  describe "Index" do
    setup [:create_user, :create_video]

    test "lists all videos", %{conn: conn, video: video, user: user} do
      {:ok, _index_live, html} = conn |> log_in_user(user) |> live(~p"/videos")

      assert html =~ "Listing Videos"
      assert html =~ video.description
    end

    test "saves new video", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = conn |> live(~p"/videos")

      assert index_live |> element("a", "New Video") |> render_click() =~
               "New Video"

      assert_patch(index_live, ~p"/videos/new")

      assert index_live
             |> form("#video-form", video: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#video-form", video: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/videos")

      assert html =~ "Video created successfully"
      assert html =~ "some description"
    end

    test "updates video in listing", %{conn: conn, video: video, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = conn |> live(~p"/videos")

      assert index_live |> element("#videos-#{video.id} a", "Edit") |> render_click() =~
               "Edit Video"

      assert_patch(index_live, ~p"/videos/#{video}/edit")

      assert index_live
             |> form("#video-form", video: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#video-form", video: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/videos")

      assert html =~ "Video updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes video in listing", %{conn: conn, video: video, user: user} do
      {:ok, index_live, _html} = conn |> log_in_user(user) |> live(~p"/videos")

      assert index_live |> element("#videos-#{video.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#video-#{video.id}")
    end
  end

  describe "Show" do
    setup [:create_user, :create_video]

    test "displays video", %{conn: conn, video: video, user: user} do
      {:ok, _show_live, html} = conn |> log_in_user(user) |> live(~p"/videos/#{video}")

      assert html =~ "Show Video"
      assert html =~ video.description
    end

    test "updates video within modal", %{conn: conn, video: video, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, show_live, _html} = conn |> live(~p"/videos/#{video}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Video"

      assert_patch(show_live, ~p"/videos/#{video}/show/edit")

      assert show_live
             |> form("#video-form", video: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#video-form", video: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/videos/#{video}")

      assert html =~ "Video updated successfully"
      assert html =~ "some updated description"
    end
  end
end
