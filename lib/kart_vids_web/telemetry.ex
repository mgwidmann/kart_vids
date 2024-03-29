defmodule KartVidsWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # Database Metrics
      summary("kart_vids.repo.query.total_time",
        unit: {:native, :millisecond},
        description: "The sum of the other measurements"
      ),
      summary("kart_vids.repo.query.decode_time",
        unit: {:native, :millisecond},
        description: "The time spent decoding the data received from the database"
      ),
      summary("kart_vids.repo.query.query_time",
        unit: {:native, :millisecond},
        description: "The time spent executing the query"
      ),
      summary("kart_vids.repo.query.queue_time",
        unit: {:native, :millisecond},
        description: "The time spent waiting for a database connection"
      ),
      summary("kart_vids.repo.query.idle_time",
        unit: {:native, :millisecond},
        description: "The time the connection spent waiting before being checked out for the query"
      ),

      # Users
      last_value("kart_vids.users.count"),

      # Race Listener Metrics
      # Doesn't seem to work, page hangs
      # distribution("kart_vids.location_listener.clock_delta"),
      summary("kart_vids.location_listener.clock_delta"),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # Nebulex
      last_value("kart_vids.racer_profile_cache.stats.hits", tags: [:cache]),
      last_value("kart_vids.racer_profile_cache.stats.misses", tags: [:cache]),
      last_value("kart_vids.racer_profile_cache.stats.writes", tags: [:cache]),
      last_value("kart_vids.racer_profile_cache.stats.updates", tags: [:cache]),
      last_value("kart_vids.racer_profile_cache.stats.evictions", tags: [:cache]),
      last_value("kart_vids.racer_profile_cache.stats.expirations", tags: [:cache])
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      {KartVids.Accounts, :count_users_metric, []},
      {KartVids.Races.RacerProfile.Cache, :dispatch_stats, []}
    ]
  end
end
