defmodule WalletTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WalletTrackerWeb.Telemetry,
      WalletTracker.Repo,
      {DNSCluster, query: Application.get_env(:wallet_tracker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WalletTracker.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WalletTracker.Finch},
      # Start a worker by calling: WalletTracker.Worker.start_link(arg)
      # {WalletTracker.Worker, arg},
      WalletTracker.DynamicSupervisor,
      # Start to serve requests, typically the last entry
      WalletTrackerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WalletTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WalletTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
