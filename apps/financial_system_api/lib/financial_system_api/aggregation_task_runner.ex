defmodule FinancialSystemApi.AggregationTaskRunner do
  @moduledoc """
  GenServer Module responsible to update aggregation tables.
  """

  use GenServer

  alias FinancialSystemApi.Accounts

  require Logger

  # Interval to update aggregations.
  @interval Application.get_env(:financial_system_api, :aggregation_interval)

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    state = get_initial_state(state)

    send(self(), :update)

    {:ok, state}
  end

  defp get_initial_state(state) do
    Map.put(state, :interval, get_interval())
  end

  defp get_interval do
    "#{@interval}"
    |> String.to_integer()
  rescue
    _e ->
      "invalid value to $AGGREGATION_INTERVAL=#{inspect(@interval)}"
      |> Logger.error()

      5_000
  end

  def handle_info(:update, state) do
    case do_update() do
      :ok ->
        "aggregation tables updated"
        |> Logger.debug()

      {:error, reason} ->
        "#{inspect(reason)}"
        |> Logger.error()
    end

    Process.send_after(self(), :update, state[:interval])

    {:noreply, state}
  rescue
    e ->
      "#{inspect(e)}"
      |> Logger.debug()

      "reseting state"
      |> Logger.debug()

      Process.send_after(self(), :update, state[:interval])

      {:noreply, get_initial_state(%{})}
  end

  defp do_update do
    if Application.get_env(:financial_system_api, :environment) == :prod do
      Accounts.update_transactions_aggregations()
    else
      :ok
    end
  end
end
