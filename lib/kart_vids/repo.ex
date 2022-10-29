defmodule KartVids.Repo do
  use Ecto.Repo,
    otp_app: :kart_vids,
    adapter: Ecto.Adapters.Postgres
end
