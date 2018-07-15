defmodule FinancialSystemApi.Statsd do
  @moduledoc """
  Wrapper module to Statsd Agent.
  """

  require DogStatsd
  require Logger

  @statsd_agent Application.get_env(:financial_system_api, :statsd_agent)

  def build_statsd_agent do
    port =
      Application.get_env(:financial_system_api, :statsd_port)
      |> get_port()

    host = Application.get_env(:financial_system_api, :statsd_host)

    case @statsd_agent.new(host, port) do
      {:ok, dogstatsd} ->
        "host: #{inspect(host)} port: #{inspect(port)}"
        |> Logger.debug()

        {:ok, dogstatsd}

      {:error, reason} ->
        "#{inspect(reason)}"
        |> Logger.error()

        {:ok, nil}
    end
  end

  def gauge(agent, tag, value) do
    @statsd_agent.gauge(agent, tag, value)

    "gauge tag: #{inspect(tag)} value: #{inspect(value)}"
    |> Logger.debug()
  end

  def histogram(agent, tag, value) do
    @statsd_agent.histogram(agent, tag, value)

    "histogram tag: #{inspect(tag)} value: #{inspect(value)}"
    |> Logger.debug()
  end

  def increment(agent, tag) do
    @statsd_agent.increment(agent, tag)

    "increment tag: #{inspect(tag)}"
    |> Logger.debug()
  end

  defp get_port(value) do
    "#{value}"
    |> String.to_integer()
  rescue
    _e ->
      "invalid value to $STATSD_PORT=#{inspect(value)}"
      |> Logger.error()

      8125
  end
end
