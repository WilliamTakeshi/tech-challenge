defmodule FinancialSystem do
  @moduledoc """
  Documentation for FinancialSystem.
  """

  @spec transfer(Account.t(), Account.t() | list(), Dinheiro.t()) ::
          {:ok, Account.t(), Account.t() | list()} | {:error, String.t()}
  @doc """
  Transfers a value from one account to one or more accounts.

  ## Example:

      iex> now = NaiveDateTime.utc_now()
      iex> account_a = Account.new!("User A", Dinheiro.new!(50, :BRL), now)
      iex> account_a.balance
      %Dinheiro{amount: 5000, currency: :BRL}
      iex> account_b = Account.new!("User B", Dinheiro.new!(50, :BRL), now)
      iex> account_b.balance
      %Dinheiro{amount: 5000, currency: :BRL}
      iex> {:ok, transf_a, transf_b} = FinancialSystem.transfer(account_a, account_b, Dinheiro.new!(25, :BRL))
      iex> transf_a.balance
      %Dinheiro{amount: 2500, currency: :BRL}
      iex> transf_b.balance
      %Dinheiro{amount: 7500, currency: :BRL}
      iex> invalid_money = %Dinheiro{amount: 1, currency: :NONE}
      iex> FinancialSystem.transfer(account_a, account_b, invalid_money)
      {:error, "'NONE' does not represent an ISO 4217 code"}
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

  ## Example:

      iex> now = NaiveDateTime.utc_now()
      iex> account_a = Account.new!("User A", Dinheiro.new!(50, :BRL), now)
      iex> account_a.balance
      %Dinheiro{amount: 5000, currency: :BRL}
      iex> account_b = Account.new!("User B", Dinheiro.new!(50, :BRL), now)
      iex> account_b.balance
      %Dinheiro{amount: 5000, currency: :BRL}
      iex> {transf_a, transf_b} = FinancialSystem.transfer!(account_a, account_b, Dinheiro.new!(25, :BRL))
      iex> transf_a.balance
      %Dinheiro{amount: 2500, currency: :BRL}
      iex> transf_b.balance
      %Dinheiro{amount: 7500, currency: :BRL}
      iex> invalid_money = %Dinheiro{amount: 1, currency: :NONE}
      iex> FinancialSystem.transfer!(account_a, account_b, invalid_money)
      ** (ArgumentError) 'NONE' does not represent an ISO 4217 code
  """
  def transfer!(from, to, value) do
    do_transfer!(from, to, value)
  end

  defp do_transfer!(from, to, value) when is_map(to) do
    {f, t} = do_transfer!(from, [%{account: to, ratio: 1}], value)
    {f, List.first(t)}
  end

  defp do_transfer!(from, to, value) when is_list(to) do
    unless Dinheiro.is_dinheiro?(value),
      do:
        raise(
          ArgumentError,
          message: ":value must be a Dinheiro struct"
        )

    unless value.amount > 0,
      do:
        raise(
          ArgumentError,
          message: ":value must be greater than zero"
        )

    ratios =
      to
      |> Enum.map(fn t -> t.ratio end)

    credits = Dinheiro.divide!(value, ratios)

    debit_account = Account.withdraw!(from, credits)

    credit_accounts =
      to
      |> Enum.map(fn t -> t.account end)
      |> get_credits(credits)
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
     Account.deposit!(
       account,
       value
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

  ## Example:

      iex> exchange_rate = 0.306956
      iex> {:ok, dollar} = Dinheiro.new(1, :USD)
      iex> {:ok, real} = FinancialSystem.exchange(dollar, :BRL, exchange_rate)
      iex> Dinheiro.to_string!(dollar) <> " = " <> Dinheiro.to_string!(real)
      "1,00 USD = 3,26 BRL"
      iex> FinancialSystem.exchange(dollar, :NONE, exchange_rate)
      {:error, "'NONE' does not represent an ISO 4217 code"}
  """
  def exchange(from, to, exchange_rate) do
    {:ok, exchange!(from, to, exchange_rate)}
  rescue
    e -> {:error, e.message}
  end

  @spec exchange!(Dinheiro.t(), atom(), float()) :: Dinheiro.t()
  @doc """
  Exchange one currency value to another.

  ## Example:

      iex> exchange_rate = 0.249414
      iex> euro = Dinheiro.new!(1, :EUR)
      iex> real = FinancialSystem.exchange!(euro, :BRL, exchange_rate)
      iex> Dinheiro.to_string!(euro) <> " = " <> Dinheiro.to_string!(real)
      "1,00 EUR = 4,01 BRL"
      iex> FinancialSystem.exchange!(euro, :NONE, exchange_rate)
      ** (ArgumentError) 'NONE' does not represent an ISO 4217 code
  """
  def exchange!(from, to, exchange_rate) do
    value = Dinheiro.to_float!(from)
    Dinheiro.new!(value / exchange_rate, to)
  end
end
