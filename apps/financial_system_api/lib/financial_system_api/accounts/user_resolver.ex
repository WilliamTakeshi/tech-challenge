defmodule FinancialSystemApi.Accounts.UserResolver do
  @moduledoc false

  alias FinancialSystemApi.Accounts

  def all(_args, _info) do
    {:ok, Accounts.list_users()}
  end
end
