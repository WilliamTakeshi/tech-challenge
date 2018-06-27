defmodule FinancialSystemApi.StatsdWrapper do
  require DogStatsd
  require Logger

  import FinancialSystemApi.DogStatsdBuilder

  @moduledoc """
  Wrapper module to Statsd Agent.
  """
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
