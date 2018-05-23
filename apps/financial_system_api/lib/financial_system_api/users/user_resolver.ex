defmodule FinancialSystemApi.Users.UserResolver do
  @moduledoc false

  alias FinancialSystemApi.Users
  alias FinancialSystemApi.MailSender
  alias FinancialSystemApiWeb.Session

  import FinancialSystemApi.Resolvers

  def all(_args, %{context: %{current_user: %{id: _id}}}) do
    {:ok, Users.list_users()}
  end

  def all(_args, _info) do
    {:error, "Not Authorized"}
  end

  def find(args, _info) do
    case Users.find(args) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end

  def register(args, _info) do
    {:ok, user} =
      args
      |> Users.register_user()
      |> response()

    MailSender.send_activation_email(user)

    {:ok, user}
  end

  def update(%{id: id, user: user_params}, _info) do
    id
    |> Users.get_user()
    |> Users.update_user(user_params)
  end

  def activate(%{id: id}, _info) do
    id
    |> Users.get_user()
    |> Users.activate_user()
  end

  def login(params, _info) do
    with {:ok, user} <- Session.authenticate(params, Users),
         {:ok, jwt, _} <- Guardian.encode_and_sign(user, :access) do
      {:ok, %{token: jwt}}
    end
  end
end
