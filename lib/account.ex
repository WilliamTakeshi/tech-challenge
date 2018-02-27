defmodule Account do
  @moduledoc """

  """

  defstruct [:user, :balance, :transactions]

  @typedoc """
      Type that represents an `Account` struct with:
      :user as String that represents the name of the owner of the account.
      :balance as Dinheiro that represents balance of the account.
      :transactions as array that contains all account movemants.
  """
  @type t :: %__MODULE__{
          user: String.t(),
          balance: Dinheiro.t(),
          transactions: list()
        }
end
