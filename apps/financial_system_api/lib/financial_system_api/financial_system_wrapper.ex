defmodule FinancialSystemApi.FinancialSystemWrapper do
  @moduledoc """
  Wrapper module of `FinancialSystem` module.
  """

  alias FinancialSystemApi.Accounts.Account, as: PersistentAccount

  @typedoc """
      Type that represents a transference with:
      :from as FinancialSystemApi.Accounts.Account that represents the debit account.
      :to as FinancialSystemApi.Accounts.Account that represents the credit account.
  """
  @type transference :: %{
          name: PersistentAccount.t(),
          username: PersistentAccount.t()
        }

  @spec format_value(Float.t(), String.t() | atom()) :: String.t()
  @doc """
  Return a formated string from a float value and an ISO 4217 code.
  ## Examples
      iex> FinancialSystemWrapper.format_value(100.0, "BRL")
      "100,00 BRL"
  """
  def format_value(amount, currency) do
    amount
    |> Dinheiro.new!(currency)
    |> Dinheiro.to_string!()
  end

  @spec create(Integer.t(), Float.t(), String.t() | atom()) ::
          {:ok, map()} | {:error, String.t()}
  @doc """
  Return a map to create a persistent Account.
  ## Examples
      iex> {:ok, account} == FinancialSystemWrapper.create(1, 100.0, "BRL")
      iex> account == {:ok,
      ...> %{
      ...>   amount: 100.0,
      ...>   currency: "BRL",
      ...>   id: nil,
      ...>   transactions: [
      ...>     %{
      ...>       account_id: nil,
      ...>       date_time: ~N[2018-07-23 19:50:12.726271],
      ...>       id: nil,
      ...>       value: 100.0
      ...>     }
      ...>   ],
      ...>   user_id: 1
      ...> }}
  """
  def create(user_id, amount, currency) do
    money = Dinheiro.new!(amount, currency)

    case Account.new("#{user_id}", money) do
      {:ok, account} ->
        {
          :ok,
          build_persistent_account(
            %{
              id: nil,
              user_id: user_id,
              amount: amount,
              currency: currency,
              transactions: []
            },
            account
          )
        }

      {:error, reason} ->
        {:error, reason}
    end
  rescue
    e -> {:error, e.message}
  end

  @spec transfer(PersistentAccount.t(), PersistentAccount.t(), Float.t()) ::
          {:ok, transference()} | {:error, String.t()}
  @doc """
  Transfers a value from one account to another and returns two persistent accounts to update the database.
  """
  def transfer(from, to, value) do
    money = Dinheiro.new!(value, from.currency)
    new_from = build_account(from)
    new_to = build_account(to)

    case FinancialSystem.transfer(new_from, new_to, money) do
      {:ok, f, t} ->
        {
          :ok,
          %{
            from: build_persistent_account(from, f),
            to: build_persistent_account(to, t)
          }
        }

      {:error, reason} ->
        {:error, reason}
    end
  rescue
    e -> {:error, e.message}
  end

  @spec withdraw(PersistentAccount.t(), Float.t()) ::
          {:ok, PersistentAccount.t()} | {:error, String.t()}
  @doc """
  Withdraw a value from one account and returns a new persistent account to update the database.
  """
  def withdraw(from, value) do
    money = Dinheiro.new!(value, from.currency)
    new_from = build_account(from)

    case Account.withdraw(new_from, money) do
      {:ok, f} ->
        {
          :ok,
          build_persistent_account(from, f)
        }

      {:error, reason} ->
        {:error, reason}
    end
  rescue
    e -> {:error, e.message}
  end

  defp build_account(account) do
    transactions =
      case is_list(account.transactions) do
        true -> build_transactions(account.transactions)
        false -> []
      end

    %AccountBuilder{}
    |> AccountBuilder.set_user("#{account.id}")
    |> AccountBuilder.set_currency(account.currency)
    |> AccountBuilder.set_balance(account.amount)
    |> AccountBuilder.set_transactions(transactions)
    |> AccountBuilder.build!()
  end

  defp build_transactions([head | tail]) do
    [
      %{date_time: head.date_time, value: head.value}
      | build_transactions(tail)
    ]
  end

  defp build_transactions([]), do: []

  defp build_persistent_account(old, new) do
    %{
      id: old.id,
      amount: Dinheiro.to_float!(new.balance),
      currency: old.currency,
      user_id: old.user_id,
      transactions:
        build_persistent_transactions(
          old.id,
          old.transactions,
          new.transactions
        )
    }
  end

  defp build_persistent_transactions(_account_id, [], []), do: []

  defp build_persistent_transactions(account_id, [old_head | old_tail], [
         new_head | new_tail
       ]) do
    [
      build_persistent_transaction(
        old_head.id,
        account_id,
        old_head.date_time,
        Dinheiro.to_float!(new_head.value)
      )
      | build_persistent_transactions(account_id, old_tail, new_tail)
    ]
  end

  defp build_persistent_transactions(account_id, [] = _old, [
         new_head | new_tail
       ]) do
    [
      build_persistent_transaction(
        nil,
        account_id,
        new_head.date_time,
        Dinheiro.to_float!(new_head.value)
      )
      | build_persistent_transactions(account_id, [], new_tail)
    ]
  end

  defp build_persistent_transaction(id, account_id, date_time, value) do
    %{
      id: id,
      account_id: account_id,
      date_time: date_time,
      value: value
    }
  end
end
