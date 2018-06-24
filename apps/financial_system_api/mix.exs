defmodule FinancialSystemApi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :financial_system_api,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {FinancialSystemApi.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :phoenix_ecto,
        :cowboy,
        :gettext,
        :postgrex,
        :absinthe,
        :absinthe_plug,
        :absinthe_ecto,
        :poison,
        :comeonin,
        :bcrypt_elixir,
        :secure_random,
        :guardian,
        :faker,
        :ex_erlstats,
        :dogstatsd,
        :bamboo
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:excoveralls, "~> 0.8.1", only: [:dev, :test]},
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:absinthe_ecto, "~> 0.1.3"},
      {:poison, "~> 3.1"},
      {:bcrypt_elixir, "~> 1.0.6"},
      {:comeonin, "~> 3.0"},
      {:secure_random, "~> 0.5.1"},
      {:guardian, "~> 0.14"},
      {:bamboo, "~> 0.8"},
      {:faker, "~> 0.10"},
      {:ex_erlstats, "~> 0.1.6"},
      {:dogstatsd, "0.0.4"},
      {:financial_system, in_umbrella: true}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
