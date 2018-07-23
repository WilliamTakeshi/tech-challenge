defmodule FinancialSystemApiWeb.PageController do
  @moduledoc false

  use FinancialSystemApiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
