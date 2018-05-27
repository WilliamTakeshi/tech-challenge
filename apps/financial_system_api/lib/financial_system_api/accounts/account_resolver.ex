defmodule FinancialSystemApi.Accounts.AccountResolver do
  @moduledoc false

  alias FinancialSystemApi.Accounts

  import FinancialSystemApi.Resolvers

  def create(args, %{context: %{current_user: %{id: id}}}) do
    %{amount: 0.0, currency: args.currency, user_id: id}
    |> Accounts.create_account()
    |> response()
  end

  def create(_args, _info) do
    {:error, "not authorized"}
  end
end
