defmodule AccountBuilderTest do
  use ExUnit.Case

  setup do
    date_time = NaiveDateTime.utc_now()
    user = "Ramon de Lemos"
    value = Dinheiro.new!(0, :BRL)
    transaction = %AccountTransaction{date_time: date_time, value: value}

    empty_account = %Account{
      user: user,
      balance: value,
      transactions: [transaction]
    }

    {:ok,
     %{
       date_time: date_time,
       user: user,
       value: value,
       empty_account: empty_account
     }}
  end

  test "building a valid account", context do
    assert context.empty_account ==
             context.user
             |> AccountBuilder.set_user()
             |> AccountBuilder.set_currency(:BRL)
             |> AccountBuilder.set_balance(0)
             |> AccountBuilder.set_transaction(context.date_time, 0)
             |> AccountBuilder.build!()
  end

  test "building an account with balance different of the sum of transactions values",
       context do
    assert {:error,
            "balance must to be equals of the sum of transactions values"} ==
             context.user
             |> AccountBuilder.set_user()
             |> AccountBuilder.set_currency(:BRL)
             |> AccountBuilder.set_balance(1)
             |> AccountBuilder.set_transaction(context.date_time, 0)
             |> AccountBuilder.build()
  end

  test "building with an invalid currency", context do
    assert {:error, "'NONE' does not represent an ISO 4217 code"} ==
             context.user
             |> AccountBuilder.set_user()
             |> AccountBuilder.set_currency("NONE")
             |> AccountBuilder.set_balance(0)
             |> AccountBuilder.build()
  end

  test "building with an invalid user", context do
    assert {:error, ":user must be a String"} ==
             0
             |> AccountBuilder.set_user()
             |> AccountBuilder.set_currency(:BRL)
             |> AccountBuilder.set_balance(0)
             |> AccountBuilder.build()
  end

  test "building with an invalid balance", context do
    assert {:error, "value 'NONE' must be integer or float"} ==
             context.user
             |> AccountBuilder.set_user()
             |> AccountBuilder.set_currency(:BRL)
             |> AccountBuilder.set_balance("NONE")
             |> AccountBuilder.build()
  end

  test "building with an invalid transaction date_time", context do
    assert {:error, ":date_time must be a NaiveDateTime struct"} ==
             context.user
             |> AccountBuilder.set_user()
             |> AccountBuilder.set_currency(:BRL)
             |> AccountBuilder.set_transaction("NONE", 1)
             |> AccountBuilder.build()
  end

  test "building with an invalid transaction value", context do
    assert {:error, "value 'NONE' must be integer or float"} ==
             context.user
             |> AccountBuilder.set_user()
             |> AccountBuilder.set_currency(:BRL)
             |> AccountBuilder.set_transaction(context.date_time, "NONE")
             |> AccountBuilder.build()
  end
end
