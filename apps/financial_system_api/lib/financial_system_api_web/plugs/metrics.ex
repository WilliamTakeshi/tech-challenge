defmodule FinancialSystemApiWeb.Plugs.Metrics do
  @moduledoc """
  Module responseble to send ecto metrics to DataDog Agent.
  """

  @behaviour Plug

  import Plug.Conn, only: [register_before_send: 2]

  alias FinancialSystemApi.StatsdWrapper

  def init(opts), do: opts

  def call(conn, _) do
    before_time = :os.timestamp()

    register_before_send(conn, fn conn ->
      after_time = :os.timestamp()
      diff = :timer.now_diff(after_time, before_time)

      {:ok, statsd} = StatsdWrapper.build_statsd_agent()

      # Exometer.update(
      #  [:financial_system_api, :graphql_api, :resp_time],
      #  diff / 1_000
      # )
      # Exometer.update(
      #  [:financial_system_api, :graphql_api, :resp_count],
      #  1
      # )

      conn
    end)
  end
end
