defmodule KartVids.MixProject do
  use Mix.Project

  def project do
    [
      app: :kart_vids,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: elixirc_options(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {KartVids.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def elixirc_options(:prod), do: [warnings_as_errors: true]
  def elixirc_options(_), do: []

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, github: "phoenixframework/phoenix", override: true},
      {:phoenix_ecto, github: "phoenixframework/phoenix_ecto", override: true},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, github: "phoenixframework/phoenix_html", override: true},
      {:phoenix_live_reload, github: "phoenixframework/phoenix_live_reload", override: true, only: :dev},
      {:phoenix_live_view, github: "mgwidmann/phoenix_live_view", branch: "fix-redirect-with-priv", override: true},
      {:heroicons, "~> 0.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, github: "phoenixframework/phoenix_live_dashboard", override: true},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:hackney, "~> 1.9"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:credo, "~> 1.6"},
      {:plug_cowboy, "~> 2.5"},
      # {:websockex, "~> 0.4.3"},
      {:websockex, github: "mgwidmann/websockex"},
      {:parent, "~> 0.12.1"},
      {:flames, "~> 0.7.0", github: "mgwidmann/flames", branch: "liveview"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
