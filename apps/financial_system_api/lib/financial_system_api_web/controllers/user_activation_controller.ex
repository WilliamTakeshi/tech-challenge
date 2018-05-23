defmodule FinancialSystemApiWeb.UserActivationController do
  use FinancialSystemApiWeb, :controller

  alias FinancialSystemApi.Users.UserResolver

  def activate(conn, %{"token" => token}) do
    case UserResolver.find(%{token: token}, nil) do
      {:ok, user} ->
        case UserResolver.activate(%{id: user.id}, nil) do
          {:ok, _user} ->
            conn |> put_status(200) |> json(%{ok: "e-mail verified"})

          nil ->
            conn |> put_status(500) |> json(%{error: "verification failed"})
        end

      {:error, _} ->
        conn |> put_status(:not_found) |> json(%{error: "invalid token"})
    end
  end
end
