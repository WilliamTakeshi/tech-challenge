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
    |> html_body(
      "<p>Please click the link below to verify your email address</p>"
    )
    |> html_body(
      "<a href=http://localhost:4000/activate/#{user.token}>Verify address</a>"
    )
    |> Mailer.deliver_now()

    user
  end
end
