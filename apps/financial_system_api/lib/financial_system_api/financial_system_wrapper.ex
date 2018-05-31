defmodule FinancialSystemApi.FinancialSystemWrapper do
  @moduledoc false

  alias FinancialSystemApi.Accounts.Account, as: PersistentAccount

  alias FinancialSystemApi.Accounts.AccountTransaction,
    as: PersistentAccountTransaction

  def validate_currency(args) do
    case Dinheiro.new(args.amount, args.currency) do
      {:ok, value} -> {:ok, value.currency |> Atom.to_string()}
      {:error, reason} -> {:error, reason}
    end
  end

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
  end

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
  end

  defp build_account(account) do
    transactions =
      case is_list(account.transactions) do
        true -> account.transactions
        false -> []
      end

    %AccountBuilder{}
    |> AccountBuilder.set_user("#{account.id}")
    |> AccountBuilder.set_currency(account.currency)
    |> AccountBuilder.set_balance(account.amount)
    |> build_transactions(transactions)
    |> AccountBuilder.build!()
  end

  defp build_transactions(builder, [head | tail]) do
    builder
    |> builder.set_transaction(head.date_time, head.value)
    |> build_transactions(tail)
  end

  defp build_transactions(builder, []), do: builder

  defp build_persistent_account(old, new) do
    account = %PersistentAccount{
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
        new_head.value.amount
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
        new_head.value.amount
      )
      | build_persistent_transactions(account_id, [], new_tail)
    ]
  end

  defp build_persistent_transaction(id, account_id, date_time, value) do
    %PersistentAccountTransaction{
      id: id,
      account_id: account_id,
      date_time: date_time,
      value: value
    }
  end
end
