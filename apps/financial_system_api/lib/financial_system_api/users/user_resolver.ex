defmodule FinancialSystemApi.Users.UserResolver do
  @moduledoc false

  alias FinancialSystemApi.Users

  import FinancialSystemApi.Resolvers

  def all(_args, _info) do
    {:ok, Users.list_users()}
  end

  def register(args, _info) do
    Users.register_user(args)
    |> response()
  end

  def login(params, _info) do
    with {:ok, user} <- FinancialSystemApiWeb.Session.authenticate(params, Users),
        {:ok, jwt, _ } <- Guardian.encode_and_sign(user, :access) do
      {:ok, %{token: jwt}}
    end
  end
end
