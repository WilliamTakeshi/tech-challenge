defmodule FinancialSystemApi.MailSender do
  @moduledoc false

  import Bamboo.Email

  alias FinancialSystemApi.Mailer

  def send_activation_email(user) do
    new_email()
    |> to(user.email)
    |> from("no-replay@financial-system-api.com")
    |> subject("FinancialSystemApi - Activate your account")
    |> html_body("<p>Thanks for signing up with us</p>")
    |> html_body("<p>Please click the link below to activate your account</p>")
    |> html_body(
      "<a href=http://localhost:4000/activate/#{user.token}>Active account</a>"
    )
    |> Mailer.deliver_now()

    user
  end

  def send_activated_email(user) do
    new_email()
    |> to(user.email)
    |> from("no-replay@financial-system-api.com")
    |> subject("FinancialSystemApi - Account activated")
    |> html_body("<p>Thanks for signing up with us</p>")
    |> html_body(
      "<p>Congratulations, your account is active and your have R$ 10,000 of balance.</p>"
    )
    |> Mailer.deliver_now()

    user
  end
end
