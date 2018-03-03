defmodule AccountTransactionTest do
  use ExUnit.Case
  doctest AccountTransaction

  test "new/2" do
    date_time = NaiveDateTime.utc_now()
    value = Dinheiro.new!(12345, :BRL)

    assert AccountTransaction.new(date_time, value) ==
             {:ok, %AccountTransaction{date_time: date_time, value: value}}

    assert AccountTransaction.new(date_time, %Dinheiro{
             amount: 600,
             currency: :NONE
           }) == {:error, "'NONE' does not represent an ISO 4217 code."}
  end

  test "new!/2" do
    date_time = NaiveDateTime.utc_now()
    value = Dinheiro.new!(12345, :BRL)

    assert AccountTransaction.new!(date_time, value) ==
             %AccountTransaction{date_time: date_time, value: value}

    assert_raise ArgumentError, fn ->
      AccountTransaction.new!(date_time, %Dinheiro{amount: 600, currency: :NONE})
    end
  end
end
