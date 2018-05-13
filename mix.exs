defmodule FinancialSystemApi.Mixfile do
  use Mix.Project

  @version "0.1.2"
  @github_url "https://github.com/ramondelemos/tech-challenge"

  def project do
    [
      app: :financial_system_api,
      name: "FinancialSystemApi",
      version: @version,
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {FinancialSystemApi, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:excoveralls, "~> 0.8.1", only: [:dev, :test]},
      {:credo, "~> 0.8.10", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.18", only: [:dev, :docs], runtime: false},
      {:ex_dinheiro, "~> 0.2.1"},
      {:mix_docker, "~> 0.5.0"}
    ]
  end

  defp description do
    """
    Tech Challenge Elixir.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Ramon de Lemos"],
      contributors: ["Ramon de Lemos"],
      links: %{"GitHub" => @github_url}
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      source_url: @github_url,
      main: "FinancialSystemApi",
      extras: ["README.md"]
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      pre_build: [
        "format",
        "credo --strict"
      ],
      build: [
        "clean",
        "pre_build",
        "coveralls"
      ],
      build_travis: [
        "pre_build",
        "coveralls.travis"
      ]
    ]
  end
end
