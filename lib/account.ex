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

    do_new(user, balance, [transaction])
  end

  defp do_new(user, balance, transactions) do
    %__MODULE__{user: user, balance: balance, transactions: transactions}
  end

  @spec execute(t(), AccountTransaction.t()) ::
          {:ok, t()} | {:error, String.t()}
  @doc """
  Execute a transaction into a new `Account` struct.

    ## Example:
        iex> user_name = "Ramon de Lemos"
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-03-23], ~T[13:59:07.005])
        iex> {:ok, money} = Dinheiro.new(0, :BRL)
        iex> {:ok, my_account} = Account.new(user_name, money, date_time)
        iex> {:ok, one_value} = Dinheiro.new(1, :BRL)
        iex> plus_one = AccountTransaction.new!(NaiveDateTime.utc_now(), one_value)
        iex> {:ok, my_new_balance} = Account.execute(my_account, plus_one)
        iex> my_new_balance.balance
        %Dinheiro{amount: 100, currency: :BRL}
        iex> {:ok, different_currency} = Dinheiro.new(1, :USD)
        iex> different_currency_transaction = AccountTransaction.new!(NaiveDateTime.utc_now(), different_currency)
        iex> Account.execute(my_new_balance, different_currency_transaction)
        {:error, "currency :USD different of :BRL"}
        iex> negative_transaction = AccountTransaction.new!(NaiveDateTime.utc_now(), Dinheiro.new!(-1.01, :BRL))
        iex> Account.execute(my_new_balance, negative_transaction)
        {:error, "not enough balance available on the account"}
        iex> Account.execute({}, negative_transaction)
        {:error, ":account must be Account struct"}
        iex> Account.execute(my_new_balance, {})
        {:error, ":transaction must be AccountTransaction struct"}

  """
  def execute(account, transaction) do
    {:ok, execute!(account, transaction)}
  rescue
    e -> {:error, e.message}
  end

  @spec execute!(t(), AccountTransaction.t()) :: t()
  @doc """
  Execute a transaction into a new `Account` struct.

    ## Example:
        iex> user_name = "Ramon de Lemos"
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-03-23], ~T[13:59:07.005])
        iex> {:ok, money} = Dinheiro.new(0, :BRL)
        iex> {:ok, my_account} = Account.new(user_name, money, date_time)
        iex> {:ok, one_value} = Dinheiro.new(1, :BRL)
        iex> plus_one = AccountTransaction.new!(NaiveDateTime.utc_now(), one_value)
        iex> my_new_balance = Account.execute!(my_account, plus_one)
        iex> my_new_balance.balance
        %Dinheiro{amount: 100, currency: :BRL}
        iex> negative_transaction = AccountTransaction.new!(NaiveDateTime.utc_now(), Dinheiro.new!(-1.01, :BRL))
        iex> Account.execute!(my_new_balance, negative_transaction)
        ** (AccountError) not enough balance available on the account

  """
  def execute!(account, transaction) do
    unless is_account?(account),
      do:
        raise(
          ArgumentError,
          message: ":account must be Account struct"
        )

    unless AccountTransaction.is_account_transaction?(transaction),
      do:
        raise(
          ArgumentError,
          message: ":transaction must be AccountTransaction struct"
        )

    do_execute(account, transaction)
  end

  defp do_execute(account, transaction) do
    calc_balance =
      account.transactions
      |> Enum.map(fn x -> x.value end)
      |> Dinheiro.sum!()

    unless Dinheiro.equals?(account.balance, calc_balance),
      do:
        raise(
          AccountError,
          message: "balance must to be equals of the sum of transactions values"
        )

    new_transactions = [transaction | account.transactions]
    new_balance = Dinheiro.sum!(calc_balance, transaction.value)

    unless new_balance.amount >= 0,
      do:
        raise(
          AccountError,
          message: "not enough balance available on the account"
        )

    do_new(account.user, new_balance, new_transactions)
  end

  @spec is_account?(t()) :: boolean()
  @doc """
  Return true if value is a `Account` struct.

  ## Example:
        iex> user_name = "Ramon de Lemos"
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-03-23], ~T[13:59:07.005])
        iex> {:ok, money} = Dinheiro.new(0, :BRL)
        iex> {:ok, my_account} = Account.new(user_name, money, date_time)
        iex> Account.is_account?(my_account)
        true
        iex> Account.is_account?({})
        false

  """
  def is_account?(%__MODULE__{user: u, balance: b, transactions: t})
      when is_binary(u) and is_list(t) do
    Dinheiro.is_dinheiro?(b) and is_list_of_account_transaction?(t)
  end

  def is_account?(_), do: false

  defp one_if_account_transaction(value) do
    case AccountTransaction.is_account_transaction?(value) do
      true -> 1
      false -> 0
    end
  end

  defp count_account_transaction([]), do: 0

  defp count_account_transaction([head | tail]),
    do: one_if_account_transaction(head) + count_account_transaction(tail)

  defp is_list_of_account_transaction?(list) do
    Enum.count(list) == count_account_transaction(list)
  end
end
