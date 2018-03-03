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

  @spec new(String.t(), Dinheiro.t(), NaiveDateTime.t()) ::
          {:ok, t()} | {:error, String.t()}
  @doc """
  Create a new `Account` struct.

  ## Example:
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-03-23], ~T[13:59:07.005])
        iex> {:ok, money} = Dinheiro.new(12345, :BRL)
        iex> Account.new("Ramon de Lemos", money, date_time)
        {:ok, %Account{user: "Ramon de Lemos", balance: %Dinheiro{amount: 1234500, currency: :BRL}, transactions: [%AccountTransaction{date_time: ~N[2018-03-23 13:59:07.005], value: %Dinheiro{amount: 1234500, currency: :BRL}}]}}

  """
  def new(user, balance, date_time) do
    {:ok, new!(user, balance, date_time)}
  rescue
    e -> {:error, e.message}
  end

  @spec new!(String.t(), Dinheiro.t(), NaiveDateTime.t()) :: t()
  @doc """
  Create a new `Account` struct.

  ## Example:
        iex> user_name = "Ramon de Lemos"
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-03-23], ~T[13:59:07.005])
        iex> {:ok, money} = Dinheiro.new(12345, :BRL)
        iex> Account.new(user_name, money, date_time) == {:ok,
        ...>  %Account{
        ...>    balance: money,
        ...>    transactions: [
        ...>      %AccountTransaction{
        ...>        date_time: date_time,
        ...>        value: money
        ...>      }
        ...>    ],
        ...>    user: user_name
        ...>  }}
        true
  """
  def new!(user, balance, date_time) do
    unless is_binary(user),
      do:
        raise(
          ArgumentError,
          message: ":user must be a String"
        )

    unless Dinheiro.is_dinheiro?(balance),
      do:
        raise(
          ArgumentError,
          message: ":balance must be a Dinheiro struct"
        )

    transaction = AccountTransaction.new!(date_time, balance)

    %Account{user: user, balance: balance, transactions: [transaction]}
  end
end
