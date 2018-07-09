defmodule FinancialSystemApiWeb.Schema.Types do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: FinancialSystemApi.Repo

  import_types(Absinthe.Type.Custom)

  object :user do
    field(:id, :id)
    field(:name, :string)
    field(:username, :string)
    field(:email, :string)
    field(:accounts, list_of(:account), resolve: assoc(:accounts))
  end

  object :account do
    field(:id, :id)
    field(:amount, :float)
    field(:currency, :string)
    field(:user, :user, resolve: assoc(:user))
    field(:transactions, list_of(:transaction), resolve: assoc(:transactions))
  end

  object :transaction do
    field(:id, :id)
    field(:date_time, :naive_datetime)
    field(:value, :float)
    field(:account, :account, resolve: assoc(:account))
  end

  object :session do
    field(:token, :string)
  end

  object :transference do
    field(:from, :account)
    field(:to, :account)
  end

  @desc "Balance type"
  enum :balance_type do
    value(:day, description: "Day")
    value(:month, description: "Month")
    value(:year, description: "Year")
    value(:total, description: "Total")
  end

  @desc "Balance result"
  object :balance_result do
    field(:date, :naive_datetime)
    field(:currency, :string)
    field(:credit, :float)
    field(:debit, :float)
  end

  @desc "Idle users"
  object :idle_users do
    field(:date, :naive_datetime)
    field(:count, :integer)
  end
end
