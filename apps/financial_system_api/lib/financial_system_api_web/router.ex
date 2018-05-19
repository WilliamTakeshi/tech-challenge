defmodule FinancialSystemApiWeb.Router do
  use FinancialSystemApiWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", FinancialSystemApiWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/api" do
    pipe_through(:api)

    forward("/", Absinthe.Plug, schema: FinancialSystemApiWeb.Schema)
  end

  scope "/graphiql" do
    pipe_through(:api)

    forward("/", Absinthe.Plug.GraphiQL, schema: FinancialSystemApiWeb.Schema)
  end
end
