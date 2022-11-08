defmodule KartVids.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: KartVids.Registry},
      # Start the Telemetry supervisor
      KartVidsWeb.Telemetry,
      # Start the Ecto repository
      KartVids.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: KartVids.PubSub},
      # Start the Endpoint (http/https)
      KartVidsWeb.Endpoint,
      # Start a worker by calling: KartVids.Worker.start_link(arg)
      # {KartVids.Worker, arg}
      {KartVids.Races.ListenerSupervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KartVids.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KartVidsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
