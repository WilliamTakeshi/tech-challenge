defmodule FinancialSystemApi.Statsd do
  @moduledoc """
  Wrapper module to Statsd Agent.
  """

  require DogStatsd
  require Logger

  @config Application.get_env(:financial_system_api, FinancialSystemApi.Statsd)

  def build_statsd_agent do
    case @config[:statsd].new(@config[:host], @config[:port]) do
      {:ok, dogstatsd} ->
        {:ok, dogstatsd}

      {:error, reason} ->
        Logger.info("#{inspect(reason)}")
        {:ok, nil}
    end
  end

  def gauge(agent, tag, value) do
    @config[:statsd].gauge(agent, tag, value)
  end

  def histogram(agent, tag, value) do
    @config[:statsd].histogram(agent, tag, value)
  end

  def increment(agent, tag) do
    @config[:statsd].increment(agent, tag)
  end
end
