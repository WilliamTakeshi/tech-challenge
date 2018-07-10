defmodule FinancialSystemApi.Users.UserResolverTest do
  use FinancialSystemApi.DataCase, async: true
  use Bamboo.Test

  alias FinancialSystemApi.Users.UserResolver
  alias FinancialSystemApi.MailSender

  @user %{
    email: "some@email",
    email_verified: true,
    name: "some name",
    password: "some password",
    username: "some username"
  }

  defp register(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user)
      |> UserResolver.register(nil)

    user
  end

  defp activate(user) do
    {:ok, activated_user} = UserResolver.activate(%{id: user.id}, nil)
    activated_user
  end

  test "all/2 authorized" do
    user = register()

    assert UserResolver.all(nil, %{context: %{current_user: %{id: user.id}}}) ==
             {:ok, [%{user | password: nil}]}
  end

  test "all/2 not authorized" do
    assert UserResolver.all(nil, nil) == {:error, "not authorized"}
  end

  test "find/2 valid user" do
    user = register()

    assert UserResolver.find(%{id: user.id}, nil) ==
             {:ok, %{user | password: nil}}
  end

  test "find/2 invalid user" do
    assert UserResolver.find(%{id: 0}, nil) == {:error, "user not found"}
  end

  test "register/2" do
    user = register()
    assert_delivered_email(MailSender.send_activation_email(user))
  end

  test "register/2 an duplicated user" do
    user = register()

    assert_delivered_email(MailSender.send_activation_email(user))

    {:error, reason} =
      @user
      |> UserResolver.register(nil)

    assert reason != nil
  end

  test "activate/2" do
    user =
      register()
      |> activate()

    balance = "1.000,00 BRL"

    assert_delivered_email(MailSender.send_activated_email(user, balance))
  end

  test "login/2" do
    user =
      register()
      |> activate()

    {:ok, login} =
      UserResolver.login(%{email: user.email, password: @user.password}, nil)

    assert login.token != nil
  end
end
