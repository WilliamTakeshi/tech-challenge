# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :financial_system_api, ecto_repos: [FinancialSystemApi.Repo]

# Configures the endpoint
config :financial_system_api, FinancialSystemApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "7V90BNoyL0X9UQHmKOXoyp6RcV/Mo/8IkW23Qt0M2hQFbryjKaoMI53xZsbdIpYJ",
  render_errors: [view: FinancialSystemApi.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FinancialSystemApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# ex_dinheiro configurations
bitcoin = %{
  XBT: %{
    name: "Bitcoin",
    symbol: '฿',
    alpha_code: "XBT",
    num_code: 0,
    exponent: 8
  }
}

config :ex_dinheiro, :unofficial_currencies, bitcoin
config :ex_dinheiro, :display_currency_symbol, false
config :ex_dinheiro, :display_currency_code, true

# mix_docker configurations.
config :mix_docker,
  image: "ramondelemos/tech-challenge",
  tag: "{mix-version}",
  dockerfile_release: "Dockerfile.release",
  dockerfile_build: "Dockerfile.build"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
