defmodule FinancialSystemApi.Accounts.Account do
  @moduledoc false
  use Ecto.Schema
  alias FinancialSystemApi.Users.User
  alias FinancialSystemApi.Accounts.AccountTransaction
  import Ecto.Changeset

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
    |> cast(attrs, [:amount, :currency])
    |> validate_required([:amount, :currency])
  end
end
