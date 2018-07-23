defmodule FinancialSystemApiWeb.UserActivationController do
  @moduledoc """
  Module responsible to activate registered users.
  """

  use FinancialSystemApiWeb, :controller

  alias FinancialSystemApi.Users.UserResolver

  @doc """
  Activate an user with the registration token.
  """
  def activate(conn, %{"token" => token}) do
    case UserResolver.find(%{token: token}, nil) do
      {:ok, user} ->
        case UserResolver.activate(%{id: user.id}, nil) do
          {:ok, _user} ->
            conn |> put_status(200) |> json(%{ok: "e-mail activated"})

          nil ->
            conn |> put_status(500) |> json(%{error: "activation failed"})
        end

      {:error, _} ->
        conn |> put_status(:not_found) |> json(%{error: "invalid token"})
    end
  end
end
