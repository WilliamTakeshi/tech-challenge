defmodule FinancialSystemApiWeb.FallbackController do
  @moduledoc false

  use FinancialSystemApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(
      FinancialSystemApiWeb.ChangesetView,
      "error.json",
      changeset: changeset
    )
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(FinancialSystemApiWeb.ErrorView, :"404")
  end
end
