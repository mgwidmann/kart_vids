defmodule KartVids.RacesTest do
  use KartVids.DataCase

  alias KartVids.Races

  describe "karts" do
    alias KartVids.Races.Kart

    import KartVids.RacesFixtures

    @invalid_attrs %{average_fastest_lap_time: nil, average_rpms: nil, fastest_lap_time: nil, kart_num: nil, number_of_races: nil}

    test "list_karts/0 returns all karts" do
      kart = kart_fixture()
      assert Races.list_karts() == [kart]
    end

    test "get_kart!/1 returns the kart with given id" do
      kart = kart_fixture()
      assert Races.get_kart!(kart.id) == kart
    end

    test "create_kart/1 with valid data creates a kart" do
      valid_attrs = %{average_fastest_lap_time: 120.5, average_rpms: 42, fastest_lap_time: 120.5, kart_num: "some kart_num", number_of_races: 42}

      assert {:ok, %Kart{} = kart} = Races.create_kart(valid_attrs)
      assert kart.average_fastest_lap_time == 120.5
      assert kart.average_rpms == 42
      assert kart.fastest_lap_time == 120.5
      assert kart.kart_num == "some kart_num"
      assert kart.number_of_races == 42
    end

    test "create_kart/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Races.create_kart(@invalid_attrs)
    end

    test "update_kart/2 with valid data updates the kart" do
      kart = kart_fixture()
      update_attrs = %{average_fastest_lap_time: 456.7, average_rpms: 43, fastest_lap_time: 456.7, kart_num: "some updated kart_num", number_of_races: 43}

      assert {:ok, %Kart{} = kart} = Races.update_kart(kart, update_attrs)
      assert kart.average_fastest_lap_time == 456.7
      assert kart.average_rpms == 43
      assert kart.fastest_lap_time == 456.7
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

  describe "races" do
    alias KartVids.Races.Race

    import KartVids.RacesFixtures

    @invalid_attrs %{ended_at: nil, external_race_id: nil, name: nil, started_at: nil}

    test "list_races/0 returns all races" do
      race = race_fixture()
      assert Races.list_races() == [race]
    end

    test "get_race!/1 returns the race with given id" do
      race = race_fixture()
      assert Races.get_race!(race.id) == race
    end

    test "create_race/1 with valid data creates a race" do
      valid_attrs = %{ended_at: ~U[2022-11-13 03:06:00Z], external_race_id: "some external_race_id", name: "some name", started_at: ~U[2022-11-13 03:06:00Z]}

      assert {:ok, %Race{} = race} = Races.create_race(valid_attrs)
      assert race.ended_at == ~U[2022-11-13 03:06:00Z]
      assert race.external_race_id == "some external_race_id"
      assert race.name == "some name"
      assert race.started_at == ~U[2022-11-13 03:06:00Z]
    end

    test "create_race/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Races.create_race(@invalid_attrs)
    end

    test "update_race/2 with valid data updates the race" do
      race = race_fixture()
      update_attrs = %{ended_at: ~U[2022-11-14 03:06:00Z], external_race_id: "some updated external_race_id", name: "some updated name", started_at: ~U[2022-11-14 03:06:00Z]}

      assert {:ok, %Race{} = race} = Races.update_race(race, update_attrs)
      assert race.ended_at == ~U[2022-11-14 03:06:00Z]
      assert race.external_race_id == "some updated external_race_id"
      assert race.name == "some updated name"
      assert race.started_at == ~U[2022-11-14 03:06:00Z]
    end

    test "update_race/2 with invalid data returns error changeset" do
      race = race_fixture()
      assert {:error, %Ecto.Changeset{}} = Races.update_race(race, @invalid_attrs)
      assert race == Races.get_race!(race.id)
    end

    test "delete_race/1 deletes the race" do
      race = race_fixture()
      assert {:ok, %Race{}} = Races.delete_race(race)
      assert_raise Ecto.NoResultsError, fn -> Races.get_race!(race.id) end
    end

    test "change_race/1 returns a race changeset" do
      race = race_fixture()
      assert %Ecto.Changeset{} = Races.change_race(race)
    end
  end

  describe "racers" do
    alias KartVids.Races.Racer

    import KartVids.RacesFixtures

    @invalid_attrs %{average_lap: nil, fastest_lap: nil, kart_num: nil, nickname: nil, photo: nil, position: nil}

    test "list_racers/0 returns all racers" do
      racer = racer_fixture()
      assert Races.list_racers() == [racer]
    end

    test "get_racer!/1 returns the racer with given id" do
      racer = racer_fixture()
      assert Races.get_racer!(racer.id) == racer
    end

    test "create_racer/1 with valid data creates a racer" do
      valid_attrs = %{average_lap: 120.5, fastest_lap: 120.5, kart_num: 42, nickname: "some nickname", photo: "some photo", position: 42}

      assert {:ok, %Racer{} = racer} = Races.create_racer(valid_attrs)
      assert racer.average_lap == 120.5
      assert racer.fastest_lap == 120.5
      assert racer.kart_num == 42
      assert racer.nickname == "some nickname"
      assert racer.photo == "some photo"
      assert racer.position == 42
    end

    test "create_racer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Races.create_racer(@invalid_attrs)
    end

    test "update_racer/2 with valid data updates the racer" do
      racer = racer_fixture()
      update_attrs = %{average_lap: 456.7, fastest_lap: 456.7, kart_num: 43, nickname: "some updated nickname", photo: "some updated photo", position: 43}

      assert {:ok, %Racer{} = racer} = Races.update_racer(racer, update_attrs)
      assert racer.average_lap == 456.7
      assert racer.fastest_lap == 456.7
      assert racer.kart_num == 43
      assert racer.nickname == "some updated nickname"
      assert racer.photo == "some updated photo"
      assert racer.position == 43
    end

    test "update_racer/2 with invalid data returns error changeset" do
      racer = racer_fixture()
      assert {:error, %Ecto.Changeset{}} = Races.update_racer(racer, @invalid_attrs)
      assert racer == Races.get_racer!(racer.id)
    end

    test "delete_racer/1 deletes the racer" do
      racer = racer_fixture()
      assert {:ok, %Racer{}} = Races.delete_racer(racer)
      assert_raise Ecto.NoResultsError, fn -> Races.get_racer!(racer.id) end
    end

    test "change_racer/1 returns a racer changeset" do
      racer = racer_fixture()
      assert %Ecto.Changeset{} = Races.change_racer(racer)
    end
  end
end
