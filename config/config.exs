# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

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
config :mix_docker, image: "ramondelemos/tech-challenge",
  tag: "{mix-version}",
  dockerfile_release: "Dockerfile.release",
  dockerfile_build: "Dockerfile.build"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"