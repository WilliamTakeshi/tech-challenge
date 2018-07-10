defmodule FinancialSystemApiWeb.GraphqlUserTest do
  use FinancialSystemApiWeb.ConnCase, async: true

  @user %{
    email: "some@email",
    name: "some name",
    password: "some password",
    username: "some username"
  }

  @query """
  {
    users {
      name,
      id,
      email,
      username
    }
  }
  """

  setup do
    user = build_an_activated_user(@user)
    {:ok, %{user: user}}
  end

  test "list all users authenticated", %{conn: conn, user: user} do
    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @query,
        variables: %{}
      )

    assert response["data"]["users"] == [
             %{
               "id" => "#{user.id}",
               "name" => user.name,
               "username" => user.username,
               "email" => user.email
             }
           ]
  end

  test "list all users not authenticated", %{conn: conn} do
    response =
      conn
      |> graphql_query(
        query: @query,
        variables: %{}
      )

    assert response ==
             %{
               "errors" => [
                 %{
                   "message" => "not authorized",
                   "locations" => [%{"column" => 0, "line" => 2}],
                   "path" => ["users"]
                 }
               ],
               "data" => %{"users" => nil}
             }
  end
end
