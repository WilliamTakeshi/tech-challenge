defmodule FinancialSystemApi.UserHelper do
  @moduledoc false

  alias FinancialSystemApi.Users.UserResolver

  def build_an_activated_user(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> UserResolver.register(nil)

    {:ok, activated_user} = UserResolver.activate(%{id: user.id}, nil)

    activated_user
  end
end
