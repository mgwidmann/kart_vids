defmodule KartVidsWeb.KartLiveTest do
  use KartVidsWeb.ConnCase

  import Phoenix.LiveViewTest
  import KartVids.RacesFixtures

  @create_attrs %{average_fastest_lap_time: 120.5, average_rpms: 42, fastest_lap_time: 120.5, kart_num: "some kart_num", number_of_races: 42}
  @update_attrs %{average_fastest_lap_time: 456.7, average_rpms: 43, fastest_lap_time: 456.7, kart_num: "some updated kart_num", number_of_races: 43}
  @invalid_attrs %{average_fastest_lap_time: nil, average_rpms: nil, fastest_lap_time: nil, kart_num: nil, number_of_races: nil}

  defp create_kart(_) do
    kart = kart_fixture()
    %{kart: kart}
  end

  describe "Index" do
    setup [:create_kart]

    test "lists all karts", %{conn: conn, kart: kart} do
      {:ok, _index_live, html} = live(conn, ~p"/karts")

      assert html =~ "Listing Karts"
      assert html =~ kart.kart_num
    end

    test "saves new kart", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/karts")

      assert index_live |> element("a", "New Kart") |> render_click() =~
               "New Kart"

      assert_patch(index_live, ~p"/karts/new")

      assert index_live
             |> form("#kart-form", kart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#kart-form", kart: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/karts")

      assert html =~ "Kart created successfully"
      assert html =~ "some kart_num"
    end

    test "updates kart in listing", %{conn: conn, kart: kart} do
      {:ok, index_live, _html} = live(conn, ~p"/karts")

      assert index_live |> element("#karts-#{kart.id} a", "Edit") |> render_click() =~
               "Edit Kart"

      assert_patch(index_live, ~p"/karts/#{kart}/edit")

      assert index_live
             |> form("#kart-form", kart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#kart-form", kart: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/karts")

      assert html =~ "Kart updated successfully"
      assert html =~ "some updated kart_num"
    end

    test "deletes kart in listing", %{conn: conn, kart: kart} do
      {:ok, index_live, _html} = live(conn, ~p"/karts")

      assert index_live |> element("#karts-#{kart.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#kart-#{kart.id}")
    end
  end

  describe "Show" do
    setup [:create_kart]

    test "displays kart", %{conn: conn, kart: kart} do
      {:ok, _show_live, html} = live(conn, ~p"/karts/#{kart}")

      assert html =~ "Show Kart"
      assert html =~ kart.kart_num
    end

    test "updates kart within modal", %{conn: conn, kart: kart} do
      {:ok, show_live, _html} = live(conn, ~p"/karts/#{kart}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Kart"

      assert_patch(show_live, ~p"/karts/#{kart}/show/edit")

      assert show_live
             |> form("#kart-form", kart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#kart-form", kart: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/karts/#{kart}")

      assert html =~ "Kart updated successfully"
      assert html =~ "some updated kart_num"
    end
  end
end
