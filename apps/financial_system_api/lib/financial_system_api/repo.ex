defmodule FinancialSystemApi.Repo do
  @moduledoc """
  Repo module responsible to handle access to PostgreSQL database.
  """

  use Ecto.Repo, otp_app: :financial_system_api

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
