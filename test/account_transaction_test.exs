defmodule AccountTransactionTest do
  use ExUnit.Case
  doctest AccountTransaction

  test "new/2" do
    date_time = NaiveDateTime.utc_now()
    value = Dinheiro.new!(12345, :BRL)

    assert AccountTransaction.new(date_time, value) ==
             {:ok, %AccountTransaction{date_time: date_time, value: value}}
  end
end
