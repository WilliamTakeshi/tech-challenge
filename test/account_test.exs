defmodule AccountTest do
  use ExUnit.Case
  doctest Account

  setup_all do
    date_time = NaiveDateTime.utc_now()
    user = "Ramon de Lemos"
    value = Dinheiro.new!(0, :BRL)
    transaction = %AccountTransaction{date_time: date_time, value: value}

    empty_account = %Account{
      user: user,
      balance: value,
      transactions: [transaction]
    }

    {:ok, %{default_values: {date_time, user, value, empty_account}}}
  end

  test "new/3", context do
    {date_time, user, value, empty_account} = context[:default_values]

    assert Account.new(user, value, date_time) == {:ok, empty_account}

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

  test "new!/3", context do
    {date_time, user, value, empty_account} = context[:default_values]

    assert Account.new!(user, value, date_time) == empty_account

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

  test "execute/2", context do
    {_date_time, _user, _value, empty_account} = context[:default_values]

    one_value = Dinheiro.new!(0.01, :BRL)
    two_value = Dinheiro.new!(0.02, :BRL)

    plus_one_transaction =
      AccountTransaction.new!(NaiveDateTime.utc_now(), one_value)

    {:ok, result_one} = Account.execute(empty_account, plus_one_transaction)

    assert Dinheiro.equals?(result_one.balance, one_value)
    assert Enum.count(result_one.transactions) == 2

    {:ok, result_two} = Account.execute(result_one, plus_one_transaction)

    assert Dinheiro.equals?(result_two.balance, two_value)
    assert Enum.count(result_two.transactions) == 3

    less_three_value = Dinheiro.new!(-0.03, :BRL)

    negative_transaction =
      AccountTransaction.new!(NaiveDateTime.utc_now(), less_three_value)

    assert Account.execute(result_two, negative_transaction) ==
             {:error, "not enough balance available on the account"}

    different_currency_value = Dinheiro.new!(0.01, :USD)

    different_currency_transaction =
      AccountTransaction.new!(NaiveDateTime.utc_now(), different_currency_value)

    assert Account.execute(result_two, different_currency_transaction) ==
             {:error, "currency :USD different of :BRL"}

    assert Account.execute({}, plus_one_transaction) ==
             {:error, ":account must be Account struct"}

    assert Account.execute(result_two, {}) ==
             {:error, ":transaction must be AccountTransaction struct"}

    invalid_account = %Account{
      user: "",
      balance: two_value,
      transactions: [plus_one_transaction]
    }

    assert Account.execute(invalid_account, plus_one_transaction) ==
             {:error,
              "balance must to be equals of the sum of transactions values"}
  end

  test "execute!/2", context do
    {_date_time, _user, _value, empty_account} = context[:default_values]

    zero_value = Dinheiro.new!(0.0, :BRL)
    one_value = Dinheiro.new!(0.01, :BRL)
    two_value = Dinheiro.new!(0.02, :BRL)

    plus_zero_transaction =
      AccountTransaction.new!(NaiveDateTime.utc_now(), zero_value)

    result_zero = Account.execute!(empty_account, plus_zero_transaction)

    assert Dinheiro.equals?(result_zero.balance, zero_value)
    assert Enum.count(result_zero.transactions) == 1

    plus_one_transaction =
      AccountTransaction.new!(NaiveDateTime.utc_now(), one_value)

    result_one = Account.execute!(empty_account, plus_one_transaction)

    assert Dinheiro.equals?(result_one.balance, one_value)
    assert Enum.count(result_one.transactions) == 2

    result_two = Account.execute!(result_one, plus_one_transaction)

    assert Dinheiro.equals?(result_two.balance, two_value)
    assert Enum.count(result_two.transactions) == 3

    less_three_value = Dinheiro.new!(-0.03, :BRL)

    negative_transaction =
      AccountTransaction.new!(NaiveDateTime.utc_now(), less_three_value)

    assert_raise AccountError, fn ->
      Account.execute!(result_two, negative_transaction)
    end

    different_currency_value = Dinheiro.new!(0.01, :USD)

    different_currency_transaction =
      AccountTransaction.new!(NaiveDateTime.utc_now(), different_currency_value)

    assert_raise ArgumentError, fn ->
      Account.execute!(result_two, different_currency_transaction)
    end

    assert_raise ArgumentError, fn ->
      Account.execute!({}, plus_one_transaction)
    end

    assert_raise ArgumentError, fn ->
      Account.execute!(result_two, {})
    end

    assert_raise ArgumentError, fn ->
      Account.execute!(result_two, [2, 1])
    end
  end

  test "is_account?/1", context do
    {date_time, user, value, empty_account} = context[:default_values]

    assert Account.is_account?(empty_account) == true

    assert Account.is_account?(%{
             user: user,
             balance: value,
             transactions: [AccountTransaction.new(date_time, value)]
           }) == false

    assert Account.is_account?(200) == false
  end
end
