defmodule FinancialSystemTest do
  use ExUnit.Case
  doctest FinancialSystem

  setup_all do
    bitcoin = %{
      XBT: %Moeda{
        name: "Bitcoin",
        symbol: '฿',
        alpha_code: "XBT",
        num_code: 0,
        exponent: 8
      }
    }

    Application.put_env(:ex_dinheiro, :unofficial_currencies, bitcoin)

    user_account =
      Account.new!(
        "User",
        Dinheiro.new!(10_000, :BRL),
        NaiveDateTime.utc_now()
      )

    another_account =
      Account.new!(
        "Another User",
        Dinheiro.new!(10_000, :BRL),
        NaiveDateTime.utc_now()
      )

    {:ok, %{user_account: user_account, another_account: another_account}}
  end

  test "User should be able to transfer money to another account", context do
    money = Dinheiro.new!(5_000, :BRL)

    {:ok, user_account, another_account} =
      FinancialSystem.transfer(
        context[:user_account],
        context[:another_account],
        money
      )

    assert Dinheiro.equals?(user_account.balance, money)

    assert Dinheiro.equals?(
             another_account.balance,
             Dinheiro.new!(15_000, :BRL)
           )
  end

  test "User cannot transfer if not enough money available on the account",
       context do
    assert FinancialSystem.transfer(
             context[:user_account],
             context[:another_account],
             Dinheiro.new!(10_000.01, :BRL)
           ) == {:error, "not enough balance available on the account"}
  end

  test "A transfer should be cancelled if an error occurs", context do
    assert FinancialSystem.transfer(
             context[:user_account],
             context[:another_account],
             Dinheiro.new!(10_000.01, :USD)
           ) == {:error, "currency :USD different of :BRL"}
  end

  test "A transfer can be splitted between 2 or more accounts", context do
    user_account = context[:user_account]

    accounts =
      Enum.map(1..10_000, fn i ->
        %{
          account:
            Account.new!(
              "User #{i}",
              Dinheiro.new!(0, :BRL),
              NaiveDateTime.utc_now()
            ),
          ratio: 1
        }
      end)

    money = Dinheiro.new!(10_000, :BRL)

    {:ok, debited_user_account, credited_accounts} =
      FinancialSystem.transfer(
        user_account,
        accounts,
        money
      )

    sum_of_splited_money =
      credited_accounts
      |> Enum.map(fn account -> account.balance end)
      |> Dinheiro.sum!()

    assert Dinheiro.equals?(user_account.balance, sum_of_splited_money)

    zero_money = Dinheiro.new!(0, :BRL)

    assert Dinheiro.equals?(debited_user_account.balance, zero_money)
  end

  test "User should be able to exchange money between different currencies" do
    bitcoin = Dinheiro.new!(1, :XBT)
    exchange_rate = 0.0000274382

    assert FinancialSystem.exchange!(bitcoin, :BRL, exchange_rate) ==
             Dinheiro.new!(36_445.54, :BRL)
  end

  test "Currencies should be in compliance with ISO 4217" do
    brl = Moeda.find!(:BRL)
    assert brl.name == "Brazilian Real"
    assert brl.symbol == 'R$'
    assert brl.alpha_code == "BRL"
    assert brl.num_code == 986
    assert brl.exponent == 2

    jpy = Moeda.find!(:JPY)
    assert jpy.name == "Yen"
    assert jpy.symbol == [165]
    assert jpy.alpha_code == "JPY"
    assert jpy.num_code == 392
    assert jpy.exponent == 0

    usd = Moeda.find!(:USD)
    assert usd.name == "US Dollar"
    assert usd.symbol == '$'
    assert usd.alpha_code == "USD"
    assert usd.num_code == 840
    assert usd.exponent == 2

    mkd = Moeda.find!(:MKD)
    assert mkd.name == "Denar"
    assert mkd.symbol == [1076, 1077, 1085]
    assert mkd.alpha_code == "MKD"
    assert mkd.num_code == 807
    assert mkd.exponent == 2

    assert Moeda.find(:NONE) ==
             {:error, "'NONE' does not represent an ISO 4217 code"}
  end
end
