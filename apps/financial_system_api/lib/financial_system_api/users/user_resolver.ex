defmodule FinancialSystemApi.Users.UserResolver do
  @moduledoc false

  alias FinancialSystemApi.Users

  def all(_args, _info) do
    {:ok, Users.list_users()}
  end

  def register(args, _info) do
    Users.register_user(args)
  end
end
