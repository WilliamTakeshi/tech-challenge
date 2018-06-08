defmodule FinancialSystemApi.GraphqlHelper do
  @moduledoc false

  use Phoenix.ConnTest

  @endpoint FinancialSystemApiWeb.Endpoint

  def graphql_query(conn, options) do
    conn
    |> post("/api", build_query(options[:query], options[:variables]))
    |> json_response(200)
  end

  defp build_query(query, variables) do
    %{
      "query" => query,
      "variables" => variables
    }
  end

  def graphql_error_message(path, message, column \\ 0, line \\ 2) do
    %{
      "errors" => [
        %{
          "message" => message,
          "locations" => [%{"column" => column, "line" => line}],
          "path" => [path]
        }
      ],
      "data" => %{"#{path}" => nil}
    }
  end
end
