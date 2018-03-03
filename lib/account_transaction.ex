defmodule AccountTransaction do
  @moduledoc """
  The `AccountTransaction` struct represents one transaction of an `Account`.
  New account transactions can be built with the `new/2`.
  """

  defstruct [:date_time, :value]

  @typedoc """
      Type that represents an AccountTransaction struct with:
      :date_time as NaiveDateTime that represents the date and time of the transaction.
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
        iex> AccountTransaction.new("2018-03-23 08:40:07.005", value)
        {:error, ":date_time must be a NaiveDateTime struct."}
        iex> AccountTransaction.new(date_time, 50)
        {:error, ":value must be a Dinheiro struct."}
        iex> AccountTransaction.new(date_time, %Dinheiro{amount: 1234500, currency: :NONE})
        {:error, "'NONE' does not represent an ISO 4217 code."}

  """
  def new(date_time, value) do
    {:ok, new!(date_time, value)}
  rescue
    e -> {:error, e.message}
  end

  @spec new!(NaiveDateTime.t(), Dinheiro.t()) :: t()
  @doc """
  Create a new `AccountTransaction` struct.

  ## Example:
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-03-23], ~T[08:40:07.005])
        iex> {:ok, value} = Dinheiro.new(12345, :BRL)
        iex> AccountTransaction.new!(date_time, value)
        %AccountTransaction{date_time: ~N[2018-03-23 08:40:07.005], value: %Dinheiro{amount: 1234500, currency: :BRL}}
        iex> AccountTransaction.new!(date_time, %Dinheiro{amount: 1234500, currency: :NONE})
        ** (ArgumentError) 'NONE' does not represent an ISO 4217 code.

  """
  def new!(date_time, value) do
    unless is_naive_date_time?(date_time),
      do:
        raise(
          ArgumentError,
          message: ":date_time must be a NaiveDateTime struct."
        )

    unless Dinheiro.is_dinheiro?(value),
      do:
        raise(
          ArgumentError,
          message: ":value must be a Dinheiro struct."
        )

    Moeda.get_atom!(value.currency)

    %AccountTransaction{date_time: date_time, value: value}
  end

  defp is_naive_date_time?(%NaiveDateTime{}), do: true
  defp is_naive_date_time?(_), do: false
end
