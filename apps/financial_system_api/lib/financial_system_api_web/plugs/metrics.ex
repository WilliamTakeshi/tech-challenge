defmodule FinancialSystemApiWeb.Plugs.Metrics do
  @moduledoc """
  Module responsible to send ecto metrics to StatsD Agent.
  """

  @behaviour Plug

  import Plug.Conn, only: [register_before_send: 2]

  alias FinancialSystemApi.Statsd

  def init(opts), do: opts

  def call(conn, _) do
    before_time = :os.timestamp()

    register_before_send(conn, fn conn ->
      after_time = :os.timestamp()
      diff = :timer.now_diff(after_time, before_time)

      {:ok, statsd} = Statsd.build_statsd_agent()

      Statsd.histogram(
        statsd,
        "financial_system_api.web.resp_time",
        diff / 1_000
      )

      Statsd.increment(statsd, "financial_system_api.web.resp_count")

      conn
    end)
  end
end
