defmodule FinancialSystemApiWeb.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias FinancialSystemApi.Users.UserResolver
  alias FinancialSystemApi.Accounts.AccountResolver

  import_types(FinancialSystemApiWeb.Schema.Types)

  query do
    @desc "List all users"
    field :users, list_of(:user) do
      resolve(&UserResolver.all/2)
    end

    @desc "Balance report"
    field :balance_report, list_of(:balance_result) do
      arg(:by, non_null(:balance_type))
      arg(:date, :date)

      resolve(&AccountResolver.balance_report/2)
    end

    @desc "Idle users more then 1 month"
    field :idle_report, :idle_users do
      resolve(&AccountResolver.idle_report/2)
    end
  end

  mutation do
    @desc "Register an user"
    field :register, type: :user do
      arg(:name, non_null(:string))
      arg(:username, non_null(:string))
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UserResolver.register/2)
    end

    @desc "Authenticate user"
    field :login, type: :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UserResolver.login/2)
    end

    @desc "Create an account"
    field :create_account, type: :account do
      arg(:currency, non_null(:string))

      resolve(&AccountResolver.create/2)
    end

    @desc "Transfer values between two accounts"
    field :transfer, type: :transference do
      arg(:from, non_null(:id))
      arg(:to, non_null(:id))
      arg(:value, non_null(:float))

      resolve(&AccountResolver.transfer/2)
    end

    @desc "Withdraw from an account"
    field :withdraw, type: :account do
      arg(:from, non_null(:id))
      arg(:value, non_null(:float))

      resolve(&AccountResolver.withdraw/2)
    end
  end
end
