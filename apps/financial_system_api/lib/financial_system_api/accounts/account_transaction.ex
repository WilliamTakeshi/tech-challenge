defmodule FinancialSystemApi.Accounts.AccountTransaction do
  @moduledoc false
  use Ecto.Schema
  alias FinancialSystemApi.Accounts.Account
  import Ecto.Changeset

  schema "transactions" do
    field(:date_time, :naive_datetime)
    field(:value, :float)
    belongs_to(:account, Account, foreign_key: :account_id)

    timestamps()
  end

  @doc false
  def changeset(account_transaction, attrs) do
    account_transaction
    |> cast(attrs, [:value, :date_time])
    |> validate_required([:value, :date_time])
  end
end
