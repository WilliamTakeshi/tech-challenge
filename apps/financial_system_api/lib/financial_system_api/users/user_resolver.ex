defmodule FinancialSystemApi.Users.UserResolver do
  @moduledoc false

  alias FinancialSystemApi.Users
  alias FinancialSystemApi.Accounts
  alias FinancialSystemApi.MailSender
  alias FinancialSystemApiWeb.Session

  import FinancialSystemApi.Resolvers

  def all(_args, %{context: %{current_user: %{id: _id}}}) do
    {:ok, Users.list_users()}
  end

  def all(_args, _info) do
    {:error, "not authorized"}
  end

  def find(args, _info) do
    case Users.find(args) do
      nil -> {:error, "user not found"}
      user -> {:ok, user}
    end
  end

  def register(args, _info) do
    {:ok, user} =
      args
      |> Users.register_user()
      |> response()

    MailSender.send_activation_email(user)
    |> MailSender.deliver()

    {:ok, user}
  end

  def activate(%{id: id}, _info) do
    user =
      id
      |> Users.get_user()

    unless user.email_verified do
      {:ok, _} =
        user
        |> Users.activate_user()

      {:ok, account} =
        %{user_id: id, amount: 10_000.00, currency: "BRL"}
        |> Accounts.create_account()

      MailSender.send_activated_email(user)
      |> MailSender.deliver()
    end

    {:ok, user}
  end

  def login(params, _info) do
    with {:ok, user} <- Session.authenticate(params, Users),
         {:ok, jwt, _} <- Guardian.encode_and_sign(user, :access) do
      {:ok, %{token: jwt}}
    end
  end
end
