defmodule FinancialSystemApiWeb.Schema.Types do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: FinancialSystemApi.Repo

  object :user do
    field(:id, :id)
    field(:name, :string)
    field(:username, :string)
    field(:email, :string)
  end

  object :session do
    field(:token, :string)
  end
end
