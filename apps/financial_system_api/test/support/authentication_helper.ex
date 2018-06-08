defmodule FinancialSystemApi.AuthenticationHelper do
  @moduledoc false

  alias FinancialSystemApi.Users.UserResolver
  alias Plug.Conn

  def authenticate_user(conn, user) do
    {:ok, login} =
      UserResolver.login(%{email: user.email, password: user.password}, nil)

    conn
    |> Conn.put_req_header("authorization", "Bearer #{login.token}")
  end
end
