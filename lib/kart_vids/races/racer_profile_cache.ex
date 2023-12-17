defmodule KartVids.Races.RacerProfile.Cache do
  use Nebulex.Cache,
    otp_app: :kart_vids,
    adapter: Nebulex.Adapters.Local

  # def stats(adapter_meta) do
  #   IO.puts("Getting stats and reset")

  #   if counter_ref = adapter_meta[:stats_counter] do
  #     new_metrics = %{
  #       hits: :counters.get(counter_ref, 1),
  #       misses: :counters.get(counter_ref, 2),
  #       writes: :counters.get(counter_ref, 3),
  #       updates: :counters.get(counter_ref, 4),
  #       evictions: :counters.get(counter_ref, 5),
  #       expirations: :counters.get(counter_ref, 6)
  #     }

  #     # Reset
  #     :counters.put(counter_ref, 1, 0)
  #     :counters.put(counter_ref, 2, 0)
  #     :counters.put(counter_ref, 3, 0)
  #     :counters.put(counter_ref, 4, 0)
  #     :counters.put(counter_ref, 5, 0)
  #     :counters.put(counter_ref, 6, 0)

  #     %Nebulex.Stats{
  #       measurements: new_metrics,
  #       metadata: %{
  #         cache: adapter_meta[:name] || adapter_meta[:cache]
  #       }
  #     }
  #   end
  # end
end
