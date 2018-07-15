defmodule FinancialSystemApi.Statsd do
  @moduledoc """
  Wrapper module to Statsd Agent.
  """

  require DogStatsd
  require Logger

  @config Application.get_env(:financial_system_api, FinancialSystemApi.Statsd)

  def build_statsd_agent do
    port =
      @config[:port]
      |> get_port()

    case @config[:statsd].new(@config[:host], port) do
      {:ok, dogstatsd} ->
        "host: #{inspect(@config[:host])} port: #{inspect(port)}"
        |> Logger.debug()

        {:ok, dogstatsd}

      {:error, reason} ->
        "#{inspect(reason)}"
        |> Logger.error()

        {:ok, nil}
    end
  end

  def gauge(agent, tag, value) do
    @config[:statsd].gauge(agent, tag, value)

    "gauge tag: #{inspect(tag)} value: #{inspect(value)}"
    |> Logger.debug()
  end

  def histogram(agent, tag, value) do
    @config[:statsd].histogram(agent, tag, value)

    "histogram tag: #{inspect(tag)} value: #{inspect(value)}"
    |> Logger.debug()
  end

  def increment(agent, tag) do
    @config[:statsd].increment(agent, tag)

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
