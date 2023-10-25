defmodule KartVidsWeb.SeasonLiveTest do
  use KartVidsWeb.ConnCase

  import Phoenix.LiveViewTest
  import KartVids.RacesFixtures

  @create_attrs %{ended: true, season: 42, start_at: "2023-10-24", weekly_start_at: "14:00", weekly_start_day: 42, number_of_meetups: 42, daily_qualifiers: 42, daily_practice: true, driver_type: 42, position_qualifier: true}
  @update_attrs %{ended: false, season: 43, start_at: "2023-10-25", weekly_start_at: "15:01", weekly_start_day: 43, number_of_meetups: 43, daily_qualifiers: 43, daily_practice: false, driver_type: 43, position_qualifier: false}
  @invalid_attrs %{ended: false, season: nil, start_at: nil, weekly_start_at: nil, weekly_start_day: nil, number_of_meetups: nil, daily_qualifiers: nil, daily_practice: false, driver_type: nil, position_qualifier: false}

  defp create_season(_) do
    season = season_fixture()
    %{season: season}
  end

  describe "Index" do
    setup [:create_season]

    test "lists all seasons", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/seasons")

      assert html =~ "Listing Seasons"
    end

    test "saves new season", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/seasons")

      assert index_live |> element("a", "New Season") |> render_click() =~
               "New Season"

      assert_patch(index_live, ~p"/seasons/new")

      assert index_live
             |> form("#season-form", season: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#season-form", season: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/seasons")

      html = render(index_live)
      assert html =~ "Season created successfully"
    end

    test "updates season in listing", %{conn: conn, season: season} do
      {:ok, index_live, _html} = live(conn, ~p"/seasons")

      assert index_live |> element("#seasons-#{season.id} a", "Edit") |> render_click() =~
               "Edit Season"

      assert_patch(index_live, ~p"/seasons/#{season}/edit")

      assert index_live
             |> form("#season-form", season: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#season-form", season: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/seasons")

      html = render(index_live)
      assert html =~ "Season updated successfully"
    end

    test "deletes season in listing", %{conn: conn, season: season} do
      {:ok, index_live, _html} = live(conn, ~p"/seasons")

      assert index_live |> element("#seasons-#{season.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#seasons-#{season.id}")
    end
  end

  describe "Show" do
    setup [:create_season]

    test "displays season", %{conn: conn, season: season} do
      {:ok, _show_live, html} = live(conn, ~p"/seasons/#{season}")

      assert html =~ "Show Season"
    end

    test "updates season within modal", %{conn: conn, season: season} do
      {:ok, show_live, _html} = live(conn, ~p"/seasons/#{season}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Season"

      assert_patch(show_live, ~p"/seasons/#{season}/show/edit")

      assert show_live
             |> form("#season-form", season: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#season-form", season: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/seasons/#{season}")

      html = render(show_live)
      assert html =~ "Season updated successfully"
    end
  end
end
