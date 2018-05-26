defmodule FinancialSystemApiWeb.UserActivationControllerTest do
  use FinancialSystemApiWeb.ConnCase

  alias FinancialSystemApi.Users.UserResolver

  @user %{
    email: "some@email",
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

  test "GET /activate/:token with a valid token", %{conn: conn} do
    user = register()
    conn = get(conn, "/activate/#{user.token}")
    assert json_response(conn, 200) == %{"ok" => "e-mail activated"}
  end

  test "GET /activate/:token with an invalid token", %{conn: conn} do
    conn = get(conn, "/activate/1234qwer")
    assert json_response(conn, 404) == %{"error" => "invalid token"}
  end
end
