defmodule FinancialSystemApiWeb.Router do
  @moduledoc false

  use FinancialSystemApiWeb, :router

  alias Guardian.Plug.VerifyHeader
  alias Guardian.Plug.LoadResource
  alias FinancialSystemApiWeb.Plugs.Context
  alias FinancialSystemApiWeb.Plugs.Metrics

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(Metrics)
  end

  pipeline :secure_api do
    plug(:accepts, ["json"])
    plug(VerifyHeader, realm: "Bearer")
    plug(LoadResource)
    plug(Context)
    plug(Metrics)
  end

  scope "/", FinancialSystemApiWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/api" do
    pipe_through(:secure_api)

    forward("/", Absinthe.Plug, schema: FinancialSystemApiWeb.Schema)
  end

  scope "/graphiql" do
    pipe_through(:secure_api)

    forward("/", Absinthe.Plug.GraphiQL, schema: FinancialSystemApiWeb.Schema)
  end

  scope "/activate", FinancialSystemApiWeb do
    pipe_through(:api)

    get("/:token", UserActivationController, :activate)
  end
end
