defmodule FinancialSystemApi.Accounts.AccountTransactionOneDay do
  @moduledoc false
  use Ecto.Schema

  @primary_key false
  schema "transactions_1day" do   
    field(:date, :naive_datetime, [source: :transaction_day])
    field(:currency, :string)
    field(:credit, :float)
    field(:debit, :float)
  end
end
