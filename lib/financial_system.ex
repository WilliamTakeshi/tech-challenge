defmodule FinancialSystem do
  @moduledoc """
  Documentation for FinancialSystem.
  """

  @spec transfer(Account.t(), Account.t() | list(), Dinheiro.t()) ::
          {:ok, Account.t(), Account.t() | list()} | {:error, String.t()}
  @doc """
  Transfers a value from one account to one or more accounts.
  """
  def transfer(from, to, value) do
    {f, t} = transfer!(from, to, value)
    {:ok, f, t}
  rescue
    e -> {:error, e.message}
  end

  @spec transfer!(Account.t(), Account.t() | list(), Dinheiro.t()) ::
          {Account.t(), Account.t() | list()}
  @doc """
  Transfers a value from one account to one or more accounts.
  """
  def transfer!(from, to, value) do
  end

  @spec exchange(Dinheiro.t(), atom(), float()) ::
          {:ok, Dinheiro.t()} | {:error, String.t()}
  @doc """
  Exchange one currency value to another.
  """
  def exchange(from, to, exchange_rate) do
    {:ok, exchange!(from, to, exchange_rate)}
  rescue
    e -> {:error, e.message}
  end

  @spec exchange!(Dinheiro.t(), atom(), float()) :: Dinheiro.t()
  @doc """
  Exchange one currency value to another.
  """
  def exchange!(from, to, exchange_rate) do
    value = Dinheiro.to_float!(from)
    Dinheiro.new!(value / exchange_rate, to)
  end
end
