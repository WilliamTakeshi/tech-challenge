defmodule AccountTransaction do
  @moduledoc """

  """

  defstruct [:date, :value]

  @typedoc """
      Type that represents an `AccountTransaction` struct with:
      :date as NaiveDateTime that represents the of the transaction.
      :value as Dinheiro that represents the value of the transaction.
  """
  @type t :: %AccountTransaction{
          date: NaiveDateTime.t(),
          value: Dinheiro.t()
        }
end
