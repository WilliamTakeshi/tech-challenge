defmodule FinancialSystemApi.Users.UserResolver do
  @moduledoc false

  import FinancialSystemApi.Resolvers

  alias FinancialSystemApi.Users
  alias FinancialSystemApi.Accounts
  alias FinancialSystemApi.MailSender
  alias FinancialSystemApi.FinancialSystemWrapper
  alias FinancialSystemApi.Statsd
  alias FinancialSystemApiWeb.Session

  require Logger

  def all(_args, %{context: %{current_user: %{id: id}}}) do
    send_metrics("list")
    Logger.info("listing users", user_id: id)
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
    send_metrics("register")

    Logger.info("registering user")

    case args
         |> Users.register_user()
         |> response() do
      {:ok, user} ->
        Logger.info("sending activation e-mail")

        user
        |> MailSender.send_activation_email()
        |> MailSender.deliver()

        {:ok, user}

      {:error, reason} ->
        Logger.info("#{inspect(reason)}")
        {:error, reason}
    end
  rescue
    e ->
      Logger.info("#{inspect(e)}")
      {:error, "#{inspect(e)}"}
  end

  def activate(%{id: id}, _info) do
    send_metrics("activate")

    Logger.info("getting user", user_id: id)

    user =
      id
      |> Users.get_user()

    if user.email_verified do
      {:ok, user}
    else
      Logger.info("activating user", user_id: id)

      {:ok, _} =
        user
        |> Users.activate_user()

      Logger.info("creating user account", user_id: id)

      case FinancialSystemWrapper.create(id, 1_000.00, "BRL") do
        {:ok, new_account} ->
          Logger.info("inserting account", user_id: id)

          {:ok, account} =
            new_account
            |> Accounts.create_account()

          formated_balance =
            account.amount
            |> FinancialSystemWrapper.format_value(account.currency)

          Logger.info("sending activated e-mail", user_id: id)

          user
          |> MailSender.send_activated_email(formated_balance)
          |> MailSender.deliver()

          {:ok, %{user | accounts: [account]}}

        {:error, reason} ->
          Logger.info("#{inspect(reason)}", user_id: id)
          {:error, reason}
      end
    end
  rescue
    e ->
      Logger.info("#{inspect(e)}")
      {:error, "#{inspect(e)}"}
  end

  def login(params, _info) do
    send_metrics("login")

    with {:ok, user} <- Session.authenticate(params, Users),
         {:ok, jwt, _} <- Guardian.encode_and_sign(user, :access) do
      send_metrics("login.ok")
      {:ok, %{token: jwt}}
    end
  rescue
    e ->
      Logger.info("#{inspect(e)}")
      {:error, "#{inspect(e)}"}
  end

  defp send_metrics(method) do
    {:ok, statsd} = Statsd.build_statsd_agent()

    if statsd do
      Statsd.increment(
        statsd,
        "financial_system_api.user.#{method}"
      )
    end
  end
end
