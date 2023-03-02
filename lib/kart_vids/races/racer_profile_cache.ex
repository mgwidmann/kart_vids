defmodule KartVids.Races.RacerProfile.Cache do
  use Nebulex.Cache,
    otp_app: :kart_vids,
    adapter: Nebulex.Adapters.Local
end
