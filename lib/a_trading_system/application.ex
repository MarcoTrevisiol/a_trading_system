defmodule ATradingSystem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ATradingSystemWeb.Telemetry,
      {Plug.Cowboy, scheme: :http, plug: BrokerDouble.FakeServer, options: [port: 8081]},
      {DNSCluster, query: Application.get_env(:a_trading_system, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ATradingSystem.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ATradingSystem.Finch},
      # Start a worker by calling: ATradingSystem.Worker.start_link(arg)
      # {ATradingSystem.Worker, arg},
      # Start to serve requests, typically the last entry
      ATradingSystemWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ATradingSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ATradingSystemWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
