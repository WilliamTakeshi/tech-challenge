defmodule FinancialSystemApi.MailSenderTest do
  use ExUnit.Case, async: true
  use Bamboo.Test

  alias FinancialSystemApi.MailSender

  @user %{
    email: "some@email",
    token: "some token"
  }

  test "build_activation_email/1" do
    host = System.get_env("APP_HOSTNAME") || "${APP_HOSTNAME}"

    email = MailSender.build_activation_email(@user)

    assert email.to == @user.email
    assert email.subject == "FinancialSystemApi - Activate your account"

    assert email.html_body =~
             "<a href=http://#{host}/activate/#{@user.token}>Active account"
  end

  test "build_activated_email/1" do
    balance = "R$ 99,99"

    email =
      @user
      |> MailSender.build_activated_email(balance)

    assert email.to == @user.email
    assert email.subject == "FinancialSystemApi - Account activated"

    assert email.html_body =~
             "Congratulations, your account is active and your have #{balance} of balance."
  end

  test "deliver/1 sending activation e-mail" do
    deliver =
      @user
      |> MailSender.build_activation_email()
      |> MailSender.deliver()

    assert deliver == :ok

    assert_delivered_email(MailSender.build_activation_email(@user))
  end

  test "deliver/1 sending activated e-mail" do
    balance = "R$ 99,99"

    deliver =
      @user
      |> MailSender.build_activated_email(balance)
      |> MailSender.deliver()

    assert deliver == :ok

    assert_delivered_email(MailSender.build_activated_email(@user, balance))
  end

  test "build_withdraw_email/3" do
    value = "R$ 00,01"
    balance = "R$ 99,99"

    email = MailSender.build_withdraw_email(@user, value, balance)

    assert email.to == @user.email
    assert email.subject == "FinancialSystemApi - Account statement"

    assert email.html_body =~
             "Your withdrawal of #{value} was successful, your current balance is #{
               balance
             }."
  end

  test "deliver/1 sending withdraw e-mail" do
    value = "R$ 00,01"
    balance = "R$ 99,99"

    deliver =
      @user
      |> MailSender.build_withdraw_email(value, balance)
      |> MailSender.deliver()

    assert deliver == :ok

    assert_delivered_email(
      MailSender.build_withdraw_email(@user, value, balance)
    )
  end
end
