defmodule KartVids.MixProject do
  use Mix.Project

  def project do
    [
      app: :kart_vids,
      version: "0.1.0",
      elixir: "~> 1.15",
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
      extra_applications: [:logger, :runtime_tools, :os_mon]
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
      {:phoenix, "~> 1.7.1"},
      {:phoenix_ecto, "~> 4.4.0"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3.1"},
      {:phoenix_live_reload, "~> 1.4.1", only: :dev},
      {:phoenix_live_view, "~> 0.18.16"},
      {:heroicons, "~> 0.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.9"},
      {:hackney, "~> 1.9"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:credo, "~> 1.6"},
      {:plug_cowboy, "~> 2.5"},
      {:tzdata, "~> 1.1"},
      # {:websockex, "~> 0.4.3"},
      {:websockex, github: "mgwidmann/websockex", branch: "report-errors"},
      {:parent, "~> 0.12.1"},
      {:flames, "~> 0.7.0", github: "mgwidmann/flames", branch: "liveview"},
      {:number, "~> 1.0"},
      {:timex, "~> 3.7.9"},
      {:contex, "~> 0.4.0"},
      {:nebulex, "~> 2.4"},
      # => When using :shards as backend
      {:shards, "~> 1.0"},
      # => When using Caching Annotations
      {:decorator, "~> 1.4"},
      {:observer_cli, "~> 1.7"},
      {:enum_type, "~> 1.1"}
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
