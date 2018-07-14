defmodule FinancialSystemApi.StatsdMock do
  @moduledoc """
  Mock module to Statsd Agent.
  """

  def new(_, _) do
    {:ok, :mock}
  end

  def gauge(:mock, _tag, _value), do: :ok

  def gauge(sender, tag, value) when is_pid(sender) do
    send(sender, {:gauge, tag, value})
  end

  def histogram(:mock, _tag, _value), do: :ok

  def histogram(sender, tag, value) when is_pid(sender) do
    send(sender, {:histogram, tag, value})
  end

  def increment(:mock, _tag), do: :ok

  def increment(sender, tag) when is_pid(sender) do
    send(sender, {:increment, tag})
  end
end
