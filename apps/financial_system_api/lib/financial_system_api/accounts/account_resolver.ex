defmodule FinancialSystemApi.Accounts.AccountResolver do
  @moduledoc false

  import FinancialSystemApi.Resolvers

  alias FinancialSystemApi.Users
  alias FinancialSystemApi.Accounts
  alias FinancialSystemApi.MailSender
  alias FinancialSystemApi.FinancialSystemWrapper
  alias FinancialSystemApi.Statsd

  require Logger

  def create(args, %{context: %{current_user: %{id: id}}}) do
    send_metrics("create.account")

    Logger.debug("creating account", user_id: id)

    case FinancialSystemWrapper.create(id, 0.0, args.currency) do
      {:ok, account} ->
        Logger.debug("inserting account", user_id: id)

        account
        |> Accounts.create_account()
        |> response()

      {:error, reason} ->
        "#{inspect(reason)}"
        |> Logger.debug(user_id: id)

        {:error, reason}
    end
  rescue
    e ->
      "#{inspect(e)}"
      |> Logger.error(user_id: id)

      {:error, "#{inspect(e)}"}
  end

  def create(_args, _info) do
    send_metrics("create.account.unauthorized")
    {:error, "not authorized"}
  end

  def transfer(args, %{context: %{current_user: %{id: id}}}) do
    send_metrics("transfer")

    Logger.debug("getting debit account", user_id: id)

    from = Accounts.get_account!(args.from)

    if from.user_id == id do
      Logger.debug("getting credit account", user_id: id)

      to = Accounts.get_account!(args.to)

      if from.id == to.id do
        {:error, "you can not transfer money to same account"}
      else
        Logger.debug("transfering values", user_id: id)

        case FinancialSystemWrapper.transfer(from, to, args.value) do
          {:ok, result} ->
            Logger.debug("updating accounts", user_id: id)

            case Accounts.update_transfer(from, result.from, to, result.to) do
              {:ok, {:ok, f, t}} ->
                {:ok, %{from: f, to: t}}

              {:error, reason} ->
                "#{inspect(reason)}"
                |> Logger.debug(user_id: id)

                {:error, reason}
            end

          {:error, reason} ->
            "#{inspect(reason)}"
            |> Logger.debug(user_id: id)

            {:error, reason}
        end
      end
    else
      {:error, "the origin account does not belongs to you"}
    end
  rescue
    e ->
      "#{inspect(e)}"
      |> Logger.error(user_id: id)

      {:error, "#{inspect(e)}"}
  end

  def transfer(_args, _info) do
    send_metrics("transfer.unauthorized")
    {:error, "not authorized"}
  end

  def withdraw(args, %{context: %{current_user: %{id: id}}}) do
    send_metrics("withdraw")

    Logger.debug("getting account", user_id: id)

    from = Accounts.get_account!(args.from)

    if from.user_id == id do
      Logger.debug("starting withdraw", user_id: id)

      case FinancialSystemWrapper.withdraw(from, args.value) do
        {:ok, f} ->
          Logger.debug("updating account", user_id: id)

          case Accounts.update_account(from, f) do
            {:ok, account} ->
              Logger.debug("notifing user", user_id: id)

              id
              |> Users.get_user()
              |> notify_user_of_withdraw(account, args.value)

              Logger.debug("withdraw completed", user_id: id)

              {:ok, account}

            {:error, reason} ->
              "#{inspect(reason)}"
              |> Logger.debug(user_id: id)

              {:error, reason}
          end

        {:error, reason} ->
          "#{inspect(reason)}"
          |> Logger.debug(user_id: id)

          {:error, reason}
      end
    else
      {:error, "this account does not belongs to you"}
    end
  rescue
    e ->
      "#{inspect(e)}"
      |> Logger.error(user_id: id)

      {:error, "#{inspect(e)}"}
  end

  def withdraw(_args, _info) do
    send_metrics("withdraw.unauthorized")
    {:error, "not authorized"}
  end

  def balance_report(args, %{context: %{current_user: %{id: _id}}}) do
    {:ok, Accounts.balance_report(args.by, args[:date])}
  end

  def balance_report(_args, _info) do
    send_metrics("balance.report.unauthorized")
    {:error, "not authorized"}
  end

  def idle_report(_args, %{context: %{current_user: %{id: _id}}}) do
    {:ok, Accounts.idle_report()}
  end

  def idle_report(_args, _info) do
    send_metrics("idle.report.unauthorized")
    {:error, "not authorized"}
  end

  defp notify_user_of_withdraw(user, account, value) do
    formated_value =
      value
      |> FinancialSystemWrapper.format_value(account.currency)

    formated_balance =
      account.amount
      |> FinancialSystemWrapper.format_value(account.currency)

    user
    |> MailSender.build_withdraw_email(formated_value, formated_balance)
    |> MailSender.deliver()
  end

  defp send_metrics(method) do
    {:ok, statsd} = Statsd.build_statsd_agent()

    Statsd.increment(
      statsd,
      "financial_system_api.account.#{method}"
    )
  end
end
