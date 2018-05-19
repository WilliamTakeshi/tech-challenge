defmodule FinancialSystemApiWeb.PageController do
  use FinancialSystemApiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
