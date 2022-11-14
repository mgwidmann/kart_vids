defmodule KartVidsWeb.RacerLiveTest do
  use KartVidsWeb.ConnCase

  import Phoenix.LiveViewTest
  import KartVids.RacesFixtures

  @create_attrs %{average_lap: 120.5, fastest_lap: 120.5, kart_num: 42, nickname: "some nickname", photo: "some photo", position: 42}
  @update_attrs %{average_lap: 456.7, fastest_lap: 456.7, kart_num: 43, nickname: "some updated nickname", photo: "some updated photo", position: 43}
  @invalid_attrs %{average_lap: nil, fastest_lap: nil, kart_num: nil, nickname: nil, photo: nil, position: nil}

  defp create_racer(_) do
    racer = racer_fixture()
    %{racer: racer}
  end

  describe "Index" do
    setup [:create_racer]

    test "lists all racers", %{conn: conn, racer: racer} do
      {:ok, _index_live, html} = live(conn, ~p"/racers")

      assert html =~ "Listing Racers"
      assert html =~ racer.nickname
    end

    test "saves new racer", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/racers")

      assert index_live |> element("a", "New Racer") |> render_click() =~
               "New Racer"

      assert_patch(index_live, ~p"/racers/new")

      assert index_live
             |> form("#racer-form", racer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#racer-form", racer: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/racers")

      assert html =~ "Racer created successfully"
      assert html =~ "some nickname"
    end

    test "updates racer in listing", %{conn: conn, racer: racer} do
      {:ok, index_live, _html} = live(conn, ~p"/racers")

      assert index_live |> element("#racers-#{racer.id} a", "Edit") |> render_click() =~
               "Edit Racer"

      assert_patch(index_live, ~p"/racers/#{racer}/edit")

      assert index_live
             |> form("#racer-form", racer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#racer-form", racer: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/racers")

      assert html =~ "Racer updated successfully"
      assert html =~ "some updated nickname"
    end

    test "deletes racer in listing", %{conn: conn, racer: racer} do
      {:ok, index_live, _html} = live(conn, ~p"/racers")

      assert index_live |> element("#racers-#{racer.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#racer-#{racer.id}")
    end
  end

  describe "Show" do
    setup [:create_racer]

    test "displays racer", %{conn: conn, racer: racer} do
      {:ok, _show_live, html} = live(conn, ~p"/racers/#{racer}")

      assert html =~ "Show Racer"
      assert html =~ racer.nickname
    end

    test "updates racer within modal", %{conn: conn, racer: racer} do
      {:ok, show_live, _html} = live(conn, ~p"/racers/#{racer}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Racer"

      assert_patch(show_live, ~p"/racers/#{racer}/show/edit")

      assert show_live
             |> form("#racer-form", racer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#racer-form", racer: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/racers/#{racer}")

      assert html =~ "Racer updated successfully"
      assert html =~ "some updated nickname"
    end
  end
end
