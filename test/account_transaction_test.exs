defmodule AccountTransactionTest do
  use ExUnit.Case
  doctest AccountTransaction

  test "new/2" do
    date_time = NaiveDateTime.utc_now()
    value = Dinheiro.new!(12345, :BRL)

    assert AccountTransaction.new(date_time, value) ==
             {:ok, %AccountTransaction{date_time: date_time, value: value}}

    assert AccountTransaction.new("2018-03-23 08:40:07.005", value) ==
             {:error, ":date_time must be a NaiveDateTime struct"}

    assert AccountTransaction.new(date_time, %{
             amount: 600,
             currency: :BRL
           }) == {:error, ":value must be a Dinheiro struct"}

    assert AccountTransaction.new(date_time, %Dinheiro{
             amount: 600,
             currency: :NONE
           }) == {:error, "'NONE' does not represent an ISO 4217 code"}
  end

  test "new!/2" do
    date_time = NaiveDateTime.utc_now()
    value = Dinheiro.new!(12345, :BRL)

    assert AccountTransaction.new!(date_time, value) ==
             %AccountTransaction{date_time: date_time, value: value}

    assert_raise ArgumentError, fn ->
      AccountTransaction.new!("2018-03-23 08:40:07.005", value)
    end

    assert_raise ArgumentError, fn ->
      AccountTransaction.new!(date_time, %{
        amount: 600,
        currency: :BRL
      })
    end

    assert_raise ArgumentError, fn ->
      AccountTransaction.new!(date_time, %Dinheiro{amount: 600, currency: :NONE})
    end
  end
end
