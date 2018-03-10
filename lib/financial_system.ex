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
    do_transfer!(from, to, value)
  end

  defp do_transfer!(from, to, value) when is_map(to) do
    {f, t} = do_transfer!(from, [%{account: to, ratio: 1}], value)
    {f, List.first(t)}
  end

  defp do_transfer!(from, to, value) when is_list(to) do
    debit =
      NaiveDateTime.utc_now()
      |> AccountTransaction.new!(Dinheiro.multiply!(value, -1))

    debit_account = Account.execute!(from, debit)

    ratios =
      to
      |> Enum.map(fn t -> t.ratio end)

    credit_accounts =
      to
      |> Enum.map(fn t -> t.account end)
      |> get_credits(Dinheiro.divide!(value, ratios))
      |> Enum.map(fn {account, value} -> execute_async(account, value) end)
      |> Enum.map(&Task.await/1)
      |> get_async_returns!()

    {debit_account, credit_accounts}
  end

  defp get_credits([account_head | account_tail], [value_head | value_tail]) do
    [{account_head, value_head} | get_credits(account_tail, value_tail)]
  end

  defp get_credits([], []), do: []

  defp execute_async(account, value) do
    Task.async(fn -> do_execute(account, value) end)
  end

  defp do_execute(account, value) do
    {:ok,
     Account.execute!(
       account,
       AccountTransaction.new!(NaiveDateTime.utc_now(), value)
     )}
  rescue
    e -> {:error, e}
  end

  defp get_async_returns!([]), do: []

  defp get_async_returns!([head | tail]) do
    case head do
      {:ok, value} -> [value | get_async_returns!(tail)]
      {:error, reason} -> raise reason
    end
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
