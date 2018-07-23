defmodule FinancialSystemApi.Accounts.AccountTransaction do
  @moduledoc """
  Module that represents a serialisable `AccountTransaction`.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias FinancialSystemApi.Accounts.Account

  @typedoc """
      Type that represents a persistent `AccountTransaction` struct with:
      :id as Integer that represents the unique identifier.
      :date_time as NaiveDateTime that represents the date and time of the transaction.
      :value as Float that represents the value of the transaction.
      :account as Account that represents the account that belongs to.
  """
  @type t :: %{
          id: Integer.t(),
          date_time: NaiveDateTime.t(),
          value: Float.t(),
          account: [Account.t()]
        }

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
