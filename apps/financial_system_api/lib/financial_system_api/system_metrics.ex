defmodule FinancialSystemApi.SystemMetrics do
  @moduledoc """
  Module responseble to send system metrics to DataDog Agent.
  """

  use GenServer

  require Logger

  alias FinancialSystemApi.Statsd

  # Interval to send metrics.
  @interval Application.get_env(:financial_system_api, :metrics_interval)

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    state = get_initial_state(state)

    send(self(), :status)

    {:ok, state}
  end

  defp get_initial_state(state) do
    name = Application.fetch_env(:financial_system_api, :rancher_service_name)

    state =
      case name do
        {:ok, value} ->
          Map.put(state, :name, Kernel.to_charlist(value))

        :error ->
          Map.put(state, :name, Kernel.to_charlist(:financial_system_api))
      end

    {:ok, statsd} = Statsd.build_statsd_agent()

    state = Map.put(state, :statsd, statsd)

    Map.put(state, :interval, get_interval())
  end

  defp get_interval do
    case Integer.parse(@interval) do
      :error -> 1_000
      {value, _} -> value
    end
  end

  def handle_info(:status, state) do
    statsd_agent = state[:statsd]

    state =
      if statsd_agent != nil do
        statsd_agent
        |> send_memory_status(state[:name])
        |> send_erlang_system_info(state[:name])
        |> send_erlang_runtime_info(state[:name])

        state
      else
        {:ok, statsd} = Statsd.build_statsd_agent()
        Map.put(state, :statsd, statsd)
      end

    Process.send_after(self(), :status, state[:interval])

    {:noreply, state}
  rescue
    e ->
      Logger.info("#{inspect(e)}")
      Logger.info("reseting state")
      Process.send_after(self(), :status, state[:interval])
      {:noreply, get_initial_state(%{})}
  end

  def send_memory_status(statsd, system_name) do
    _result =
      ExErlstats.memory()
      |> Stream.filter(fn {_k, v} -> valid_stat?(v) end)
      |> Enum.map(fn {k, v} ->
        tag = "#{system_name}.memory" |> get_tag(k)
        Statsd.gauge(statsd, tag, v)
      end)

    statsd
  end

  def send_erlang_system_info(statsd, system_name) do
    _result =
      ExErlstats.memory()
      |> Stream.filter(fn {_k, v} -> valid_stat?(v) end)
      |> Enum.map(fn {k, v} ->
        tag = "#{system_name}.erlang" |> get_tag(k)
        Statsd.gauge(statsd, tag, v)
      end)

    statsd
  end

  def send_erlang_runtime_info(statsd, system_name) do
    _result =
      ExErlstats.memory()
      |> Stream.filter(fn {_k, v} -> valid_stat?(v) end)
      |> Enum.map(fn {k, v} ->
        tag = "#{system_name}.erlang" |> get_tag(k)
        Statsd.gauge(statsd, tag, v)
      end)

    statsd
  end

  defp valid_stat?(v), do: is_bitstring(v) || is_integer(v) || is_float(v)

  defp get_tag(system_name, v) when is_atom(v) do
    sufix =
      v
      |> Atom.to_string()
      |> String.downcase()
      |> String.replace("_", ".")

    "#{system_name}.#{sufix}"
  end

  defp get_tag(system_name, v), do: system_name <> "." <> v
end
