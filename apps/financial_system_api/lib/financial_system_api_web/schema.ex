defmodule FinancialSystemApiWeb.Schema do
  @moduledoc false

  alias FinancialSystemApi.Users.UserResolver

  use Absinthe.Schema
  import_types(FinancialSystemApiWeb.Schema.Types)

  query do
    field :users, list_of(:user) do
      resolve(&UserResolver.all/2)
    end
  end

  mutation do
    field :register, type: :user do
      arg(:name, non_null(:string))
      arg(:username, non_null(:string))
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UserResolver.register/2)
    end

    field :login, type: :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UserResolver.login/2)
    end
  end
end
