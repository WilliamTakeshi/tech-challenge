defmodule FinancialSystemApi.AggregationTaskRunner do
  @moduledoc """
  Module responseble to update aggregations tables.
  """

  use GenServer

  alias FinancialSystemApi.Accounts

  require Logger

  # Interval to update aggregations.
  @interval Application.get_env(:financial_system_api, :aggregation_interval)

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
    case Integer.parse(@interval) do
      :error -> 5_000
      {value, _} -> value
    end
  end

  def handle_info(:update, state) do
    case do_update() do
      :ok -> Logger.info("aggregation tables updated")
      {:error, reason} -> Logger.info("error: #{inspect(reason)}")
    end

    Process.send_after(self(), :update, state[:interval])

    {:noreply, state}
  rescue
    e ->
      Logger.info("#{inspect(e)}")
      Logger.info("reseting state")
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
