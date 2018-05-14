use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :financial_system_api, FinancialSystemApi.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :financial_system_api, FinancialSystemApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_DATABASE"),
  hostname: System.get_env("DB_HOSTNAME"),
  pool: Ecto.Adapters.SQL.Sandbox
