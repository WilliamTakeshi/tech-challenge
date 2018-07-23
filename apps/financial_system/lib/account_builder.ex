defmodule AccountBuilder do
  @moduledoc """
  Builder module of `Account` struct.
  """

  defstruct [:user, :balance, :currency, :transactions]

  @typedoc """
      Type that represents a transaction of an AccountBuilder struct with:
      :date_time as NaiveDateTime that represents the date and time of the transaction.
      :value as Float that represents the value of the transaction.
  """
  @type transaction :: %{
          date_time: NaiveDateTime.t(),
          value: Float.t()
        }

  @typedoc """
      Type that represents a AccountBuilder struct with:
      :user as String that represents the user unique identifier.
      :balance as Float that represents the balance of the account.
      :currency as String or Atom that represents the ISO 4217 code of the account.
      :transactions as array of transaction.
  """
  @type t :: %{
          user: String.t(),
          balance: Float.t(),
          currency: String.t() | atom(),
          transactions: [AccountBuilder.transaction()]
        }

  @spec set_user(AccountBuilder.t(), String.t()) :: AccountBuilder.t()
  @doc """
  Set the user identifier in a `AccountBuilder` struct.

  ## Example:
        iex> user_id = "1"
        iex> %AccountBuilder{} |> AccountBuilder.set_user(user_id)
        %AccountBuilder{user: "1", balance: nil, currency: nil, transactions: nil}
  """
  def set_user(params \\ %__MODULE__{}, user) do
    %{params | :user => user}
  end

  @spec set_currency(AccountBuilder.t(), String.t() | atom()) ::
          AccountBuilder.t()
  @doc """
  Set the currency in a `AccountBuilder` struct.

  ## Example:
        iex> currency = "BRL"
        iex> builder = %AccountBuilder{user: "1", balance: nil, currency: nil, transactions: nil}
        iex> builder |> AccountBuilder.set_currency(currency)
        %AccountBuilder{user: "1", balance: nil, currency: "BRL", transactions: nil}
  """
  def set_currency(params \\ %__MODULE__{}, currency) do
    %{params | :currency => currency}
  end

  @spec set_balance(AccountBuilder.t(), Float.t()) :: AccountBuilder.t()
  @doc """
  Set the balance in a `AccountBuilder` struct.

  ## Example:
        iex> balance = 1.23
        iex> builder = %AccountBuilder{user: "1", balance: nil, currency: "BRL", transactions: nil}
        iex> builder |> AccountBuilder.set_balance(balance)
        %AccountBuilder{user: "1", balance: 1.23, currency: "BRL", transactions: nil}
  """
  def set_balance(params \\ %__MODULE__{}, balance) do
    %{params | :balance => balance}
  end

  @spec set_transactions(AccountBuilder.t(), [AccountBuilder.transaction()]) ::
          AccountBuilder.t()
  @doc """
  Set the transactions in a `AccountBuilder` struct.

  ## Example:
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-07-23], ~T[15:08:07.335])
        iex> transactions = [%{date_time: date_time, value: 1.23}]
        iex> %AccountBuilder{} |> AccountBuilder.set_transactions(transactions)
        %AccountBuilder{user: nil, balance: nil, currency: nil, transactions: [%{date_time: ~N[2018-07-23 15:08:07.335], value: 1.23}]}
  """
  def set_transactions(params \\ %__MODULE__{}, transactions) do
    %{params | :transactions => transactions}
  end

  @spec build(AccountBuilder.t()) :: {:ok, Account.t()} | {:error, String.t()}
  @doc """
  Build an `Account` struct from a valid `AccountBuilder` struct.

  ## Example:
        iex> user_id = "1"
        iex> balance = 1.23
        iex> currency = :BRL
        iex> {:ok, money} = Dinheiro.new(balance, currency)
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-07-23], ~T[15:08:07.335])
        iex> transactions = [%{date_time: date_time, value: balance}]
        iex> builder = %AccountBuilder{} |> AccountBuilder.set_user(user_id)
        iex> builder = builder |> AccountBuilder.set_balance(balance)
        iex> builder = builder |> AccountBuilder.set_currency(currency)
        iex> builder = builder |> AccountBuilder.set_transactions(transactions)
        iex> {:ok, account} = builder |> AccountBuilder.build()
        iex> account == %Account{
        ...>    balance: money,
        ...>    transactions: [
        ...>      %AccountTransaction{
        ...>        date_time: date_time,
        ...>        value: money
        ...>      }
        ...>    ],
        ...>    user: user_id
        ...>  }
        true
  """
  def build(params \\ %__MODULE__{}) do
    {:ok, build!(params)}
  rescue
    e -> {:error, e.message}
  end

  @spec build!(AccountBuilder.t()) :: Account.t()
  @doc """
  Build an `Account` struct from a valid `AccountBuilder` struct.

  ## Example:
        iex> user_id = "1"
        iex> balance = 1.23
        iex> currency = :BRL
        iex> {:ok, money} = Dinheiro.new(balance, currency)
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-07-23], ~T[15:08:07.335])
        iex> transactions = [%{date_time: date_time, value: balance}]
        iex> builder = %AccountBuilder{} |> AccountBuilder.set_user(user_id)
        iex> builder = builder |> AccountBuilder.set_balance(balance)
        iex> builder = builder |> AccountBuilder.set_currency(currency)
        iex> builder = builder |> AccountBuilder.set_transactions(transactions)
        iex> account = builder |> AccountBuilder.build!()
        iex> account == %Account{
        ...>    balance: money,
        ...>    transactions: [
        ...>      %AccountTransaction{
        ...>        date_time: date_time,
        ...>        value: money
        ...>      }
        ...>    ],
        ...>    user: user_id
        ...>  }
        true
  """
  def build!(params \\ %__MODULE__{}) do
    if params.transactions do
      account =
        Account.new!(
          params.user,
          Dinheiro.new!(0.0, params.currency)
        )

      transactions =
        params.transactions
        |> build_transactions!(params.currency)
        |> deal_with_empty_list(Dinheiro.new!(params.balance, params.currency))

      account = Account.execute!(account, transactions)

      account = %{account | transactions: transactions}

      unless Dinheiro.equals?(
               account.balance,
               Dinheiro.new!(params.balance, params.currency)
             ),
             do:
               raise(
                 AccountError,
                 message:
                   "balance must to be equals of the sum of transactions values"
               )

      account
    else
      Account.new!(
        params.user,
        Dinheiro.new!(params.balance, params.currency)
      )
    end
  end

  defp build_transactions!([head | tail], currency) do
    value = Dinheiro.new!(head.value, currency)

    [
      AccountTransaction.new!(head.date_time, value)
      | build_transactions!(tail, currency)
    ]
  end

  defp build_transactions!([], _currency), do: []

  defp deal_with_empty_list([head | tail], _value) do
    [head | tail]
  end

  defp deal_with_empty_list([], value) do
    [AccountTransaction.new!(NaiveDateTime.utc_now(), value)]
  end
end
