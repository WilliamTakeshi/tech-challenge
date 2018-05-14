use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :financial_system_api, FinancialSystemApi.Endpoint,
  http: [:inet6, port: {:system, "PORT"} || "${PORT}"],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :financial_system_api, FinancialSystemApi.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :financial_system_api, FinancialSystemApi.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :financial_system_api, FinancialSystemApi.Endpoint, server: true
#

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :financial_system_api, FinancialSystemApi.Endpoint,
  secret_key_base: {:system, "SECRET_KEY"} || "${SECRET_KEY}"

# Configure your database
config :financial_system_api, FinancialSystemApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: {:system, "DB_USERNAME"} || "${DB_USERNAME}",
  password: {:system, "DB_PASSWORD"} || "${DB_PASSWORD}",
  database: {:system, "DB_DATABASE"} || "${DB_DATABASE}",
  hostname: {:system, "DB_HOSTNAME"} || "${DB_HOSTNAME}",
  ssl: true,
  pool_size: 15
