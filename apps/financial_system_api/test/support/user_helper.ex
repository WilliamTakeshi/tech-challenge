defmodule FinancialSystemApi.UserHelper do
  @moduledoc false

  alias FinancialSystemApi.Users.User
  alias FinancialSystemApi.Users.UserResolver
  alias FinancialSystemApi.Accounts.Account
  alias FinancialSystemApi.Accounts.AccountTransaction
  alias FinancialSystemApi.Repo

  def build_an_activated_user(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> UserResolver.register(nil)

    {:ok, activated_user} = UserResolver.activate(%{id: user.id}, nil)

    activated_user
  end

  def build_an_idle_user do
    user = %User{
      id: nil,
      email: "idle_user@email.com",
      email_verified: true,
      name: "idle_user",
      password_hash: "idle_password",
      token: "idle_token",
      username: "idle_user",
      accounts: [
        %Account{
          amount: 0.1,
          currency: "BRL",
          user_id: nil,
          transactions: [
            %AccountTransaction{
              date_time:
                NaiveDateTime.add(
                  NaiveDateTime.utc_now(),
                  86_400 * -32
                ),
              value: 0.1,
              account_id: nil
            }
          ]
        }
      ]
    }

    user
    |> Repo.insert()
  end
end
