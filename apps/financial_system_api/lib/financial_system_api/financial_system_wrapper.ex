defmodule FinancialSystemApi.FinancialSystemWrapper do
  @moduledoc false

  alias FinancialSystemApi.Accounts.Account, as: PersistentAccount

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
      {:ok, f, t}
        ->  {
              :ok,
              from: %PersistentAccount{
                amount: Dinheiro.to_float!(f.balance),
                currency:  Atom.to_string(f.balance.currency),
                user_id: from.user_id
              },
              to: %PersistentAccount{
                amount: Dinheiro.to_float!(t.balance),
                currency:  Atom.to_string(t.balance.currency),
                user_id: to.user_id
              }
            }
      {:error, reason}
        -> {:error, reason}
    end
  end

  defp build_account(account) do
    transactions = account.transactions || []

    %Account{
      user: "#{account.id}",
      balance: Dinheiro.new!(account.amount, account.currency),
      transactions: build_transactions(transactions, account.currency)
    }
  end

  defp build_transaction(transaction, currency) do
    %AccountTransaction{
      date_time: transaction.date_time,
      value: Dinheiro.new!(transaction.value, currency)
    }
  end

  defp build_transactions([head | tail], currency) do
    [build_transaction(head, currency) | build_transactions(tail, currency)]
  end

  defp build_transactions([], _currency), do: []
end
