defmodule FinancialSystemApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :financial_system_api,
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:mix_docker, "~> 0.5.0"},
      {:excoveralls, "~> 0.8.1", only: [:dev, :test]},
      {:credo, "~> 0.9.2", only: [:dev, :test], runtime: false}
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
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      pre_build: [
        "format",
        "credo --strict"
      ],
      build: [
        "clean",
        "ecto.create --quiet",
        "ecto.migrate",
        "pre_build",
        "coveralls --umbrella"
      ],
      build_travis: [
        "ecto.create --quiet",
        "ecto.migrate",
        "pre_build",
        "coveralls.travis --umbrella"
      ]
    ]
  end
end
