defmodule FinancialSystemApi.Accounts.AccountResolver do
  @moduledoc false

  alias FinancialSystemApi.Accounts
  alias FinancialSystemApi.FinancialSystemWrapper

  import FinancialSystemApi.Resolvers

  def create(args, %{context: %{current_user: %{id: id}}}) do
    currency = %{amount: 0.0, currency: args.currency}

    case FinancialSystemWrapper.validate_currency(currency) do
      {:ok, value} ->
        %{amount: 0.0, currency: value, user_id: id}
        |> Accounts.create_account()
        |> response()

      {:error, reason} ->
        {:error, reason}
    end
  end

  def create(_args, _info) do
    {:error, "not authorized"}
  end

  def transfer(args, %{context: %{current_user: %{id: id}}}) do
    from = Accounts.get_account!(args.from)

    if from.user_id == id do
      to = Accounts.get_account!(args.to)

      if from.id == to.id do
        {:error, "you can not transfer money to same account"}
      else
        FinancialSystemWrapper.transfer(from, to, args.value)
      end
    else
      {:error, "the origin account does not belongs to you"}
    end
  end

  def transfer(_args, _info) do
    {:error, "not authorized"}
  end
end
