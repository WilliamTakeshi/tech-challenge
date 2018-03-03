defmodule AccountTransaction do
  @moduledoc """
  The `AccountTransaction` struct represents one transaction of an `Account`.
  New account transactions can be built with the `new/2`.
  """

  defstruct [:date_time, :value]

  @typedoc """
      Type that represents an `AccountTransaction` struct with:
      :date_time as NaiveDateTime that represents the of the transaction.
      :value as Dinheiro that represents the value of the transaction.
  """
  @type t :: %__MODULE__{
          date_time: NaiveDateTime.t(),
          value: Dinheiro.t()
        }

  @spec new(NaiveDateTime.t(), Dinheiro.t()) :: {:ok, t} | {:error, String.t()}
  @doc """
  Create a new `AccountTransaction` struct.

  ## Example:
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-03-23], ~T[08:40:07.005])
        iex> {:ok, value} = Dinheiro.new(12345, :BRL)
        iex> AccountTransaction.new(date_time, value)
        {:ok, %AccountTransaction{date_time: ~N[2018-03-23 08:40:07.005], value: %Dinheiro{amount: 1234500, currency: :BRL}}}

  """
  def new(date_time, value) do
  end

  @spec new!(NaiveDateTime.t(), Dinheiro.t()) :: t()
  @doc """
  Create a new `AccountTransaction` struct.

  ## Example:
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-03-23], ~T[08:40:07.005])
        iex> {:ok, value} = Dinheiro.new(12345, :BRL)
        iex> AccountTransaction.new!(date_time, value)
        %AccountTransaction{date_time: ~N[2018-03-23 08:40:07.005], value: %Dinheiro{amount: 1234500, currency: :BRL}}

  """
  def new!(date_time, value) do
  end
end
