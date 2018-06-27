defmodule FinancialSystemApi.DogStatsdBuilder do
  require DogStatsd
  require Logger

  @moduledoc """
  Builder module to DogStatsd Agent.
  """
  def build_dogstatsd_agent do
    if Application.get_env(:financial_system_api, :environment) == :prod do
      dogstatsd_ip =
        Application.fetch_env(:financial_system_api, :rancher_host_ip)

      case dogstatsd_ip do
        {:ok, value} ->
          case DogStatsd.new(value, 8125) do
            {:ok, dogstatsd} ->
              {:ok, dogstatsd}

            {:error, reason} ->
              Logger.info("#{inspect(reason)}")
              {:ok, nil}
          end

        :error ->
          Logger.info(":rancher_host_ip not found")
          {:ok, nil}
      end
    else
      {:ok, nil}
    end
  end
end
