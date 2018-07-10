defmodule FinancialSystemApi.StatsdWrapper do
  @moduledoc """
  Wrapper module to Statsd Agent.
  """

  @behaviour FinancialSystemApi.Statsd

  require DogStatsd

  import FinancialSystemApi.DogStatsdBuilder

  def build_statsd_agent do
    build_dogstatsd_agent()
  end

  def gauge(agent, tag, value) do
    DogStatsd.gauge(agent, tag, value)
  end

  def histogram(agent, tag, value) do
    DogStatsd.histogram(agent, tag, value)
  end

  def increment(agent, tag) do
    DogStatsd.increment(agent, tag)
  end
end
