defmodule FinancialSystemApi.Application do
  @moduledoc false

  use Application

  alias FinancialSystemApi.Repo
  alias FinancialSystemApiWeb.Endpoint

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Doing remomended configuration from distillery docs
    Application.put_env(
      :financial_system_api,
      :statsd_host,
      System.get_env("STATSD_HOSTNAME") || "${STATSD_HOSTNAME}"
    )

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Repo, []),
      # Start the endpoint when the application starts
      supervisor(Endpoint, []),
      # Start your own worker by calling:
      #     FinancialSystemApi.Worker.start_link(arg1, arg2, arg3)
      # worker(FinancialSystemApi.Worker, [arg1, arg2, arg3]),
      worker(FinancialSystemApi.Rancher, []),
      worker(FinancialSystemApi.SystemMetrics, []),
      worker(FinancialSystemApi.AggregationTaskRunner, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
