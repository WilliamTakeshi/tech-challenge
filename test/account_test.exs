defmodule AccountTest do
  use ExUnit.Case
  doctest Account

  test "new/2" do
    user = "Ramon de Lemos"
    date_time = NaiveDateTime.utc_now()
    value = Dinheiro.new!(12345, :BRL)
    transactions = [%AccountTransaction{date_time: date_time, value: value}]

    assert Account.new(user, value, date_time) ==
             {:ok,
              %Account{user: user, balance: value, transactions: transactions}}

    assert Account.new(5, value, date_time) ==
             {:error, ":user must be a String"}

    assert Account.new(user, value, "2018-03-23 08:40:07.005") ==
             {:error, ":date_time must be a NaiveDateTime struct"}

    assert Account.new(user, 5, date_time) ==
             {:error, ":balance must be a Dinheiro struct"}

    assert Account.new(
             user,
             %Dinheiro{
               amount: 600,
               currency: :NONE
             },
             date_time
           ) == {:error, "'NONE' does not represent an ISO 4217 code"}
  end

  test "new!/2" do
    user = "Ramon de Lemos"
    date_time = NaiveDateTime.utc_now()
    value = Dinheiro.new!(12345, :BRL)
    transactions = [%AccountTransaction{date_time: date_time, value: value}]

    assert Account.new!(user, value, date_time) ==
             %Account{user: user, balance: value, transactions: transactions}

    assert_raise ArgumentError, fn ->
      Account.new!(5, value, date_time)
    end

    assert_raise ArgumentError, fn ->
      Account.new!(user, value, "2018-03-23 08:40:07.005")
    end

    assert_raise ArgumentError, fn ->
      Account.new!(user, 5, date_time)
    end

    assert_raise ArgumentError, fn ->
      Account.new!(
        user,
        %Dinheiro{
          amount: 600,
          currency: :NONE
        },
        date_time
      )
    end
  end
end
