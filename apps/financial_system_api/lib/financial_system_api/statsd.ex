defmodule FinancialSystemApi.Statsd do
  @moduledoc """
  Wrapper module to StatsD Agent.
  """

  require DogStatsd
  require Logger

  @statsd_agent Application.get_env(:financial_system_api, :statsd_agent)

  @doc """
  Build a configured StatsD agent.
  """
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

  @doc """
  Send to statsd agent a gauge metric.

  ## Example:
      iex> {:ok, agent} = Statsd.build_statsd_agent()
      iex> Statsd.gauge(agent, "erlang.memory.system", 15867984)
  """
  def gauge(agent, tag, value) do
    @statsd_agent.gauge(agent, tag, value)

    "gauge tag: #{inspect(tag)} value: #{inspect(value)}"
    |> Logger.debug()
  end

  @doc """
  Send to statsd agent a histogram metric.

  ## Example:
      iex> {:ok, agent} = Statsd.build_statsd_agent()
      iex> Statsd.histogram(agent, "phoenix.request.resp_time", 0.5)
  """
  def histogram(agent, tag, value) do
    @statsd_agent.histogram(agent, tag, value)

    "histogram tag: #{inspect(tag)} value: #{inspect(value)}"
    |> Logger.debug()
  end

  @doc """
  Send to statsd agent an increment metric.

  ## Example:
      iex> {:ok, agent} = Statsd.build_statsd_agent()
      iex> Statsd.increment(agent, "ecto.query.count")
  """
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
