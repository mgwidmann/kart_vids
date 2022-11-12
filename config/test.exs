import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :kart_vids, KartVids.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "kart_vids_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kart_vids, KartVidsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "AkONXA/E5TUcjYqOCS3MjwSeYaY2FM2pE1DY2ddqh4v5zPutVYxevO6VRCPRm8EG",
  server: false

# In test we don't send emails.
config :kart_vids, KartVids.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Configure video storage location
config :kart_vids,
  videos_bucket_name: "videos-bucket"

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
