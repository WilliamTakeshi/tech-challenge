defmodule FinancialSystemApi.MailSender do
  @moduledoc false

  import Bamboo.Email

  alias FinancialSystemApi.Mailer

  @doc """
  Build an activation e-mail to an user.
  """
  def build_activation_email(user) do
    host = System.get_env("APP_HOSTNAME") || "${APP_HOSTNAME}"

    user
    |> create_email()
    |> subject("FinancialSystemApi - Activate your account")
    |> html_body(
      "<a href=http://#{host}/activate/#{user.token}>Active account</a>"
    )
  end

  @doc """
  Build an activated e-mail to an user.
  """
  def build_activated_email(user, balance) do
    user
    |> create_email()
    |> subject("FinancialSystemApi - Account activated")
    |> html_body(
      "<p>Congratulations, your account is active and your have #{balance} of balance.</p>"
    )
  end

  @doc """
  Build a withdraw notification to an user.
  """
  def build_withdraw_email(user, value, balance) do
    user
    |> create_email()
    |> subject("FinancialSystemApi - Account statement")
    |> html_body(
      "<p>Your withdrawal of #{value} was successful, your current balance is #{
        balance
      }.</p>"
    )
  end

  @doc """
  Send an e-mail.
  """
  def deliver(email) do
    email
    |> Mailer.deliver_now()
  end

  defp create_email(user) do
    new_email()
    |> to(user.email)
    |> from("no-replay@financial-system-api.com")
  end
end
