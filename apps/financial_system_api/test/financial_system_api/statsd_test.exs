defmodule FinancialSystemApi.StatsdTest do
  use ExUnit.Case, async: true

  alias FinancialSystemApi.Statsd

  setup do
    {:ok, %{statsd: self()}}
  end

  test "sending gauge metrics", %{statsd: statsd} do
    Statsd.gauge(statsd, "test gauge", 1)

    receive do
      {:gauge, tag, value} ->
        assert tag == "test gauge"
        assert value == 1
    after
      # wait 50ms for this message, else fails
      50 ->
        assert false
    end
  end

  test "sending histogram metrics", %{statsd: statsd} do
    Statsd.histogram(statsd, "test histogram", 1)

    receive do
      {:histogram, tag, value} ->
        assert tag == "test histogram"
        assert value == 1
    after
      # wait 50ms for this message, else fails
      50 ->
        assert false
    end
  end

  test "sending increment metrics", %{statsd: statsd} do
    Statsd.increment(statsd, "test increment")

    receive do
      {:increment, tag} ->
        assert tag == "test increment"
    after
      # wait 50ms for this message, else fails
      50 ->
        assert false
    end
  end
end
