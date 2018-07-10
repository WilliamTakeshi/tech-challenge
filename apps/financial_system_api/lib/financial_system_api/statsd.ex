defmodule FinancialSystemApi.Statsd do
  @moduledoc """
  Interface module to Statsd Agent.
  """

  @statsd Application.get_env(:financial_system_api, :statsd)

  @callback build_statsd_agent :: {:ok, atom() | pid()} | :error
  @callback gauge(
              agent :: atom() | pid(),
              tag :: String.t(),
              value :: Integer.t() | Float.t()
            ) :: :ok | nil
  @callback histogram(
              agent :: atom() | pid(),
              tag :: String.t(),
              value :: Integer.t() | Float.t()
            ) :: :ok | nil
  @callback increment(agent :: atom() | pid(), tag :: String.t()) :: :ok | nil

  def build_statsd_agent do
    @statsd.build_statsd_agent()
  end

  def gauge(agent, tag, value) do
    @statsd.gauge(agent, tag, value)
  end

  def histogram(agent, tag, value) do
    @statsd.histogram(agent, tag, value)
  end

  def increment(agent, tag) do
    @statsd.increment(agent, tag)
  end
end
