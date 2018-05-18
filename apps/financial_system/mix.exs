defmodule FinancialSystem.Mixfile do
  use Mix.Project

  @version "0.1.2"
  @github_url "https://github.com/ramondelemos/tech-challenge"

  def project do
    [
      app: :financial_system,
      name: "FinancialSystem",
      version: @version,
      elixir: "~> 1.6",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excoveralls, "~> 0.8.1", only: [:dev, :test]},
      {:credo, "~> 0.8.10", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.18", only: [:dev, :docs], runtime: false},
      {:ex_dinheiro, "~> 0.2.1"}
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
      main: "FinancialSystem",
      extras: ["README.md"]
    ]
  end

  defp aliases do
    [
      pre_build: [
        "docs",
        &set_env_to_test/1
      ],
      post_build: [
        "format",
        "credo --strict"
      ],
      build: [
        "clean",
        "pre_build",
        "coveralls",
        "post_build"
      ],
      build_travis: [
        "pre_build",
        "coveralls.travis",
        "post_build"
      ]
    ]
  end

  defp set_env_to_test(_) do
    Mix.env(:test)
  end
end
