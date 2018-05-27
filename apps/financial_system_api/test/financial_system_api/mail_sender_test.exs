defmodule FinancialSystemApi.MailSenderTest do
  use ExUnit.Case
  use Bamboo.Test

  alias FinancialSystemApi.MailSender

  @user %{
    email: "some@email",
    token: "some token"
  }

  test "send_activation_email/1" do
    email = MailSender.send_activation_email(@user)

    assert email.to == @user.email
    assert email.subject == "FinancialSystemApi - Activate your account"

    assert email.html_body =~
             "<a href=http://localhost:4000/activate/#{@user.token}>Active account"
  end

  test "send_activated_email/1" do
    email = MailSender.send_activated_email(@user)

    assert email.to == @user.email
    assert email.subject == "FinancialSystemApi - Account activated"

    assert email.html_body =~
             "Congratulations, your account is active and your have R$ 10,000 of balance."
  end

  test "deliver/1 sending activation e-mail" do
    @user
    |> MailSender.send_activation_email()
    |> MailSender.deliver()

    assert_delivered_email(MailSender.send_activation_email(@user))
  end

  test "deliver/1 sending activated e-mail" do
    @user
    |> MailSender.send_activated_email()
    |> MailSender.deliver()

    assert_delivered_email(MailSender.send_activated_email(@user))
  end
end