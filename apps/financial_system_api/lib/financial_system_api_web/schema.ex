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
end
