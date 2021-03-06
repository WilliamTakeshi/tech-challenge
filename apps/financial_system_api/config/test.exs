use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :financial_system_api, FinancialSystemApiWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :financial_system_api, FinancialSystemApi.Repo,
  pool: Ecto.Adapters.SQL.Sandbox

# Configures Bamboo.
config :financial_system_api, FinancialSystemApi.Mailer,
  adapter: Bamboo.TestAdapter

# Configuring the test enviroment
config :financial_system_api, :environment, :test

# Configuring interval to send metrics.
config :financial_system_api, :metrics_interval, 1_000

# Configuring interval to update aggregation tables.
config :financial_system_api, :aggregation_interval, 5_000
