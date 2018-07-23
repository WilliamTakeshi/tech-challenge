defmodule FinancialSystemApi.GuardianSerializer do
  @moduledoc """
  Module responsible to serialize and deserialize the user id from jwt token.
  """

  @behaviour Guardian.Serializer

  alias FinancialSystemApi.Repo
  alias FinancialSystemApi.Users.User

  @doc false
  def for_token(%User{} = user), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  @doc false
  def from_token("User:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, "Unknown resource type"}
end
