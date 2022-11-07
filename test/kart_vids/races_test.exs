defmodule KartVids.RacesTest do
  use KartVids.DataCase

  alias KartVids.Races

  describe "karts" do
    alias KartVids.Races.Kart

    import KartVids.RacesFixtures

    @invalid_attrs %{average_fastest_lap_time: nil, average_rpms: nil, fasest_lap_time: nil, kart_num: nil, number_of_races: nil}

    test "list_karts/0 returns all karts" do
      kart = kart_fixture()
      assert Races.list_karts() == [kart]
    end

    test "get_kart!/1 returns the kart with given id" do
      kart = kart_fixture()
      assert Races.get_kart!(kart.id) == kart
    end

    test "create_kart/1 with valid data creates a kart" do
      valid_attrs = %{average_fastest_lap_time: 120.5, average_rpms: 42, fasest_lap_time: 120.5, kart_num: "some kart_num", number_of_races: 42}

      assert {:ok, %Kart{} = kart} = Races.create_kart(valid_attrs)
      assert kart.average_fastest_lap_time == 120.5
      assert kart.average_rpms == 42
      assert kart.fasest_lap_time == 120.5
      assert kart.kart_num == "some kart_num"
      assert kart.number_of_races == 42
    end

    test "create_kart/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Races.create_kart(@invalid_attrs)
    end

    test "update_kart/2 with valid data updates the kart" do
      kart = kart_fixture()
      update_attrs = %{average_fastest_lap_time: 456.7, average_rpms: 43, fasest_lap_time: 456.7, kart_num: "some updated kart_num", number_of_races: 43}

      assert {:ok, %Kart{} = kart} = Races.update_kart(kart, update_attrs)
      assert kart.average_fastest_lap_time == 456.7
      assert kart.average_rpms == 43
      assert kart.fasest_lap_time == 456.7
      assert kart.kart_num == "some updated kart_num"
      assert kart.number_of_races == 43
    end

    test "update_kart/2 with invalid data returns error changeset" do
      kart = kart_fixture()
      assert {:error, %Ecto.Changeset{}} = Races.update_kart(kart, @invalid_attrs)
      assert kart == Races.get_kart!(kart.id)
    end

    test "delete_kart/1 deletes the kart" do
      kart = kart_fixture()
      assert {:ok, %Kart{}} = Races.delete_kart(kart)
      assert_raise Ecto.NoResultsError, fn -> Races.get_kart!(kart.id) end
    end

    test "change_kart/1 returns a kart changeset" do
      kart = kart_fixture()
      assert %Ecto.Changeset{} = Races.change_kart(kart)
    end
  end
end
