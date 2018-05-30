defmodule AccountBuilder do
  @moduledoc false

  defstruct [:user, :balance, :currency, :transactions]

  def set_user(params \\ %__MODULE__{}, user) do
    %{params | :user => user}
  end

  def set_currency(params \\ %__MODULE__{}, currency) do
    %{params | :currency => currency}
  end

  def set_balance(params \\ %__MODULE__{}, balance) do
    %{params | :balance => balance}
  end

  def set_transaction(params \\ %__MODULE__{}, date_time, value) do
    transactions = params.transactions || []

    %{
      params
      | :transactions =>
          List.flatten([transactions, [%{date_time: date_time, value: value}]])
    }
  end

  def build(params \\ %__MODULE__{}) do
    {:ok, build!(params)}
  rescue
    e -> {:error, e.message}
  end

  def build!(params \\ %__MODULE__{}) do
    if params.transactions do
      account =
        Account.new!(
          params.user,
          Dinheiro.new!(0.0, params.currency)
        )

      transactions =
        params.transactions
        |> build_transactions!(params.currency)

      account =
        account
        |> Account.execute!(transactions)

      unless Dinheiro.equals?(
               account.balance,
               Dinheiro.new!(params.balance, params.currency)
             ) do
        raise(
          AccountError,
          message: "balance must to be equals of the sum of transactions values"
        )
      end

      account
    else
      Account.new!(
        params.user,
        Dinheiro.new!(params.balance, params.currency)
      )
    end
  end

  defp build_transactions!([head | tail], currency) do
    value = Dinheiro.new!(head.value, currency)

    [
      AccountTransaction.new!(head.date_time, value)
      | build_transactions!(tail, currency)
    ]
  end

  defp build_transactions!([], _currency), do: []
end
