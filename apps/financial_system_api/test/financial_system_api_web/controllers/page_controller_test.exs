defmodule FinancialSystemApiWeb.PageControllerTest do
  use FinancialSystemApiWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Bem vindo(a)!"
  end
end
