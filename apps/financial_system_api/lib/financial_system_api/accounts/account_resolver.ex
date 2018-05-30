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
    to = Accounts.get_account!(args.to)

    FinancialSystemWrapper.transfer(from, to, args.value)
  end

  def transfer(_args, _info) do
    {:error, "not authorized"}
  end
end
