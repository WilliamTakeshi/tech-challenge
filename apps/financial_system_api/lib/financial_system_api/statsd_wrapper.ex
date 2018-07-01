defmodule FinancialSystemApi.StatsdWrapper do
  require DogStatsd
  require Logger

  import FinancialSystemApi.DogStatsdBuilder

  defstruct [:mock]

  @moduledoc """
  Wrapper module to Statsd Agent.
  """
  def build_statsd_agent do
    if Application.get_env(:financial_system_api, :environment) == :prod do
      build_dogstatsd_agent()
    else
      {:ok, %__MODULE__{mock: true}}
    end
  end

  def gauge(agent, tag, value) when is_pid(agent) do
    DogStatsd.gauge(agent, tag, value)
  end

  def gauge(%__MODULE__{mock: _mock}, tag, value) do
    log = "tag=#{tag}, value=#{value}"

    log
    |> Logger.debug()
  end

  def histogram(agent, tag, value) when is_pid(agent) do
    DogStatsd.histogram(agent, tag, value)
  end

  def histogram(%__MODULE__{mock: _mock}, tag, value) do
    log = "tag=#{tag}, value=#{value}"

    log
    |> Logger.debug()
  end

  def increment(agent, tag) when is_pid(agent) do
    DogStatsd.increment(agent, tag)
  end

  def increment(%__MODULE__{mock: _mock}, tag) do
    log = "tag=#{tag}"

    log
    |> Logger.debug()
  end
end
