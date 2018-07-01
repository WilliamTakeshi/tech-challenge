# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :financial_system_api,
  namespace: FinancialSystemApi,
  ecto_repos: [FinancialSystemApi.Repo]

# Configures the endpoint
config :financial_system_api, FinancialSystemApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY") || "${SECRET_KEY}",
  render_errors: [
    view: FinancialSystemApiWeb.ErrorView,
    accepts: ~w(html json)
  ],
  pubsub: [name: FinancialSystemApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Guardian
config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "FinancialSystemApi",
  ttl: {30, :days},
  verify_issuer: true,
  secret_key: System.get_env("SECRET_KEY") || "${SECRET_KEY}",
  serializer: FinancialSystemApi.GuardianSerializer

# Configures Bamboo.
config :financial_system_api, FinancialSystemApi.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: System.get_env("BAMBOO_API_KEY") || "${BAMBOO_API_KEY}",
  domain: System.get_env("BAMBOO_DOMAIN") || "${BAMBOO_DOMAIN}"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :module, :function, :user_id]

# Configure your database
config :financial_system_api, FinancialSystemApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USERNAME") || "${DB_USERNAME}",
  password: System.get_env("DB_PASSWORD") || "${DB_PASSWORD}",
  database:
    (System.get_env("DB_DATABASE") || "financial_system_api") <> "_#{Mix.env()}",
  hostname: System.get_env("DB_HOSTNAME") || "${DB_HOSTNAME}",
  loggers: [
    {Ecto.LogEntry, :log, []},
    {FinancialSystemApi.Repo.Metrics, :log, []}
  ]

# Configuring interval to send metrics.
config :financial_system_api,
       :metrics_interval,
       System.get_env("METRICS_INTERVAL") || "${METRICS_INTERVAL}"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
