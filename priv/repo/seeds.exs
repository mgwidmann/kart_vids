# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     KartVids.Repo.insert!(%KartVids.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

KartVids.Content.create_location!(%{
  name: "Autobahn Speedway Dulles",
  street: "45448 E Severn Way #150",
  city: "Sterling",
  state: "VA",
  code: "20166",
  country: "USA",
  adult_kart_min: 1,
  adult_kart_max: 29,
  junior_kart_min: 30,
  junior_kart_max: 59
})
