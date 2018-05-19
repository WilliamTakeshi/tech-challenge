defmodule FinancialSystemApi.MixProject do
  use Mix.Project

  @version "0.1.2"

  def project do
    [
      version: @version,
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
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
      {:mix_docker, "~> 0.5.0"}
    ]
  end

  defp aliases do
    [
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
