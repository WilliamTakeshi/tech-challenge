defmodule FinancialSystemApiWeb.GraphqlAccountTest do
  use FinancialSystemApiWeb.ConnCase

  @user %{
    email: "some@email",
    name: "some name",
    password: "some password",
    username: "some username"
  }

  @query """
  mutation CreateAccount($currency: String!) {
    createAccount(currency: $currency) {
      id
      , amount
      , currency
      , user {
        id
      }
    }
  }
  """

  setup do
    user = build_an_activated_user(@user)
    {:ok, %{user: user}}
  end

  test "create an account to an authenticated user", %{conn: conn, user: user} do
    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @query,
        variables: %{
          currency: "BRL"
        }
      )

    assert response["data"]["createAccount"]["currency"] == "BRL"
    assert response["data"]["createAccount"]["amount"] == 0.0
    assert response["data"]["createAccount"]["user"]["id"] == "#{user.id}"
  end

  test "create an account to an authenticated user with an inválid currency", %{
    conn: conn
  } do
    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @query,
        variables: %{
          currency: "NONE"
        }
      )

    assert response ==
             %{
               "errors" => [
                 %{
                   "message" => "'NONE' does not represent an ISO 4217 code",
                   "locations" => [%{"column" => 0, "line" => 2}],
                   "path" => ["createAccount"]
                 }
               ],
               "data" => %{"createAccount" => nil}
             }
  end

  test "create an account to an not authenticated user", %{conn: conn} do
    response =
      conn
      |> graphql_query(
        query: @query,
        variables: %{
          currency: "BRL"
        }
      )

    assert response ==
             %{
               "errors" => [
                 %{
                   "message" => "not authorized",
                   "locations" => [%{"column" => 0, "line" => 2}],
                   "path" => ["createAccount"]
                 }
               ],
               "data" => %{"createAccount" => nil}
             }
  end
end
