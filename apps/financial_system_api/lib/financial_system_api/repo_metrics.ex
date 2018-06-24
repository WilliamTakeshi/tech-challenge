defmodule FinancialSystemApi.Repo.Metrics do
  @moduledoc """
  Module responseble to send ecto metrics to DataDog Agent.
  """

  alias FinancialSystemApi.StatsdWrapper

  def log(log_entry) do
    {:ok, statsd} = StatsdWrapper.build_statsd_agent()

    #Exometer.update(
    #  [:financial_system_api, :ecto, :query_exec_time],
    #  (log_entry.query_time + log_entry.queue_time || 0) / 1_000
    #)
    #Exometer.update(
    #  [:financial_system_api, :ecto, :query_queue_time],
    #  (log_entry.queue_time || 0) / 1_000
    #)
    #Exometer.update(
    #  [:financial_system_api, :ecto, :query_count],
    #  1
    #)
  end
end
