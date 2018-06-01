defmodule FinancialSystemApi.MailSender do
  @moduledoc false

  import Bamboo.Email

  alias FinancialSystemApi.Mailer

  def send_activation_email(user) do
    user
    |> create_email()
    |> subject("FinancialSystemApi - Activate your account")
    |> html_body(
      "<a href=http://localhost:4000/activate/#{user.token}>Active account</a>"
    )
  end

  def send_activated_email(user) do
    user
    |> create_email()
    |> subject("FinancialSystemApi - Account activated")
    |> html_body(
      "<p>Congratulations, your account is active and your have R$ 1,000 of balance.</p>"
    )
  end

  def send_withdraw_email(user, value, balance) do
    user
    |> create_email()
    |> subject("FinancialSystemApi - Account statement")
    |> html_body(
      "<p>Your withdrawal of #{value} was successful, your current balance is #{
        balance
      }.</p>"
    )
  end

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
