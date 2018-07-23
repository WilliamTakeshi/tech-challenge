defmodule FinancialSystemApi.Accounts.Account do
  @moduledoc """
  Module that represents a persistent `Account`.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias FinancialSystemApi.Users.User
  alias FinancialSystemApi.Accounts.AccountTransaction

  @typedoc """
      Type that represents a persistent `Account` struct with:
      :id as Integer that represents the unique identifier.
      :amount as Float that represents balance of the account.
      :currency as String that represents currency of the account.
      :user as FinancialSystemApi.Users.User that represents the owner of the account.
      :transactions as array of FinancialSystemApi.Accounts.AccountTransaction that contains all account transactions.
  """
  @type t :: %{
          id: Integer.t(),
          amount: Float.t(),
          currency: String.t(),
          user: User.t(),
          transactions: [AccountTransaction.t()]
        }

  schema "accounts" do
    field(:amount, :float)
    field(:currency, :string)
    belongs_to(:user, User, foreign_key: :user_id)
    has_many(:transactions, AccountTransaction)

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:amount, :currency, :user_id])
    |> validate_required([:amount, :currency, :user_id])
  end
end
