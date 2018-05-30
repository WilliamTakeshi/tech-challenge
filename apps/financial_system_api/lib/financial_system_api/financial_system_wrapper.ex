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
      {:ok, f, t} ->
        {
          :ok,
          %{
            from: %PersistentAccount{
              amount: Dinheiro.to_float!(f.balance),
              currency: Atom.to_string(f.balance.currency),
              user_id: from.user_id
            },
            to: %PersistentAccount{
              amount: Dinheiro.to_float!(t.balance),
              currency: Atom.to_string(t.balance.currency),
              user_id: to.user_id
            }
          }
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
end
