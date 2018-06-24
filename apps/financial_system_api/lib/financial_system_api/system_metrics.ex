defmodule FinancialSystemApi.SystemMetrics do
  @moduledoc """
  Module responseble to send system metrics to DataDog Agent.
  """

  use GenServer

  require Logger

  alias FinancialSystemApi.StatsdWrapper

  # try to connect every 5 seconds
  @interval 2_000

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

    {:ok, statsd} = StatsdWrapper.build_statsd_agent()

    Map.put(state, :statsd, statsd)
  end

  def handle_info(:status, state) do
    statsd_agent = state[:statsd]

    state =
      if statsd_agent != nil do
        statsd_agent
        |> send_memory_status(state[:name])

        state
      else
        {:ok, statsd} = StatsdWrapper.build_statsd_agent()
        Map.put(state, :statsd, statsd)
      end

    Process.send_after(self(), :status, @interval)

    {:noreply, state}
  rescue
    e ->
      Logger.info("#{inspect(e)}")
      Logger.info("reseting state")
      Process.send_after(self(), :status, @interval)
      {:noreply, get_initial_state(%{})}
  end

  def send_memory_status(statsd, system_name) do
    _result =
      ExErlstats.memory()
      |> Stream.filter(fn {_k, v} -> valid_stat?(v) end)
      |> Enum.map(fn {k, v} ->
        tag = "#{system_name}.memory" |> get_tag(k)
        StatsdWrapper.gauge(statsd, tag, v)
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
