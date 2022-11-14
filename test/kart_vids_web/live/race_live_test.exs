defmodule KartVidsWeb.RaceLiveTest do
  use KartVidsWeb.ConnCase

  import Phoenix.LiveViewTest
  import KartVids.RacesFixtures

  @create_attrs %{ended_at: "2022-11-13T03:06:00Z", external_race_id: "some external_race_id", name: "some name", started_at: "2022-11-13T03:06:00Z"}
  @update_attrs %{ended_at: "2022-11-14T03:06:00Z", external_race_id: "some updated external_race_id", name: "some updated name", started_at: "2022-11-14T03:06:00Z"}
  @invalid_attrs %{ended_at: nil, external_race_id: nil, name: nil, started_at: nil}

  defp create_race(_) do
    race = race_fixture()
    %{race: race}
  end

  describe "Index" do
    setup [:create_race]

    test "lists all races", %{conn: conn, race: race} do
      {:ok, _index_live, html} = live(conn, ~p"/races")

      assert html =~ "Listing Races"
      assert html =~ race.external_race_id
    end

    test "saves new race", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/races")

      assert index_live |> element("a", "New Race") |> render_click() =~
               "New Race"

      assert_patch(index_live, ~p"/races/new")

      assert index_live
             |> form("#race-form", race: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#race-form", race: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/races")

      assert html =~ "Race created successfully"
      assert html =~ "some external_race_id"
    end

    test "updates race in listing", %{conn: conn, race: race} do
      {:ok, index_live, _html} = live(conn, ~p"/races")

      assert index_live |> element("#races-#{race.id} a", "Edit") |> render_click() =~
               "Edit Race"

      assert_patch(index_live, ~p"/races/#{race}/edit")

      assert index_live
             |> form("#race-form", race: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#race-form", race: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/races")

      assert html =~ "Race updated successfully"
      assert html =~ "some updated external_race_id"
    end

    test "deletes race in listing", %{conn: conn, race: race} do
      {:ok, index_live, _html} = live(conn, ~p"/races")

      assert index_live |> element("#races-#{race.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#race-#{race.id}")
    end
  end

  describe "Show" do
    setup [:create_race]

    test "displays race", %{conn: conn, race: race} do
      {:ok, _show_live, html} = live(conn, ~p"/races/#{race}")

      assert html =~ "Show Race"
      assert html =~ race.external_race_id
    end

    test "updates race within modal", %{conn: conn, race: race} do
      {:ok, show_live, _html} = live(conn, ~p"/races/#{race}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Race"

      assert_patch(show_live, ~p"/races/#{race}/show/edit")

      assert show_live
             |> form("#race-form", race: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#race-form", race: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/races/#{race}")

      assert html =~ "Race updated successfully"
      assert html =~ "some updated external_race_id"
    end
  end
end
