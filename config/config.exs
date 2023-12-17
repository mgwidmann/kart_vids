# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :kart_vids,
  ecto_repos: [KartVids.Repo]

# Configures the endpoint
config :kart_vids, KartVidsWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: KartVidsWeb.ErrorHTML, json: KartVidsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: KartVids.PubSub,
  live_view: [signing_salt: "Wo9oMCGs"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :kart_vids, KartVids.Mailer, adapter: Swoosh.Adapters.Local

config :kart_vids,
  aws_access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  aws_secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :flames,
  repo: KartVids.Repo,
  timezone: "America/New_York",
  endpoint: KartVidsWeb.Endpoint

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger,
  backends: [:console, Flames.Logger]

config :logger, truncate: :infinity
config :logger, :console, truncate: :infinity

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :kart_vids,
  aws_region: "us-east-1"

config :kart_vids, KartVids.Races.RacerProfile.Cache,
  stats: true,
  telemetry: true,
  telemetry_prefix: [:kart_vids, :racer_profile_cache],
  backend: :shards,
  gc_interval: :timer.hours(12),
  # Max entries in cache
  max_size: 1000,
  # Max memory in cache in bytes
  allocated_memory: 150_000,
  # GC min timeout: 10 sec
  gc_cleanup_min_timeout: :timer.seconds(10),
  # GC max timeout: 10 min
  gc_cleanup_max_timeout: :timer.minutes(10)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
