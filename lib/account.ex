defmodule Account do
  @moduledoc """

  """

  defstruct [:user, :balance, :transactions]

  @typedoc """
      Type that represents an Account struct with:
      :user as String that represents the name of the owner of the account.
      :balance as Dinheiro that represents balance of the account.
      :transactions as array that contains all account transactions.
  """
  @type t :: %__MODULE__{
          user: String.t(),
          balance: Dinheiro.t(),
          transactions: [AccountTransaction.t()]
        }

  @spec new(String.t(), Dinheiro.t()) :: {:ok, t()} | {:error, String.t()}
  @doc """
  Create a new `Account` struct.

  ## Example:
        iex> user_name = "Ramon de Lemos"
        iex> {:ok, money} = Dinheiro.new(12345, :BRL)
        iex> {:ok, account} = Account.new(user_name, money)
        iex> Account.is_account?(account)
        true
        iex> Account.new(user_name, %Dinheiro{amount: 1, currency: :NONE})
        {:error, "'NONE' does not represent an ISO 4217 code"}
  """
  def new(user, balance) do
    {:ok, new!(user, balance)}
  rescue
    e -> {:error, e.message}
  end

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

  @spec new!(String.t(), Dinheiro.t()) :: t()
  @doc """
  Create a new `Account` struct.

  ## Example:
        iex> user_name = "Ramon de Lemos"
        iex> {:ok, money} = Dinheiro.new(12345, :BRL)
        iex> account = Account.new!(user_name, money)
        iex> Account.is_account?(account)
        true
        iex> Account.new!(user_name, %Dinheiro{amount: 1, currency: :NONE})
        ** (ArgumentError) 'NONE' does not represent an ISO 4217 code
  """
  def new!(user, balance) do
    new!(user, balance, NaiveDateTime.utc_now())
  end

  @spec new!(String.t(), Dinheiro.t(), NaiveDateTime.t()) :: t()
  @doc """
  Create a new `Account` struct.

  ## Example:

        iex> user_name = "Ramon de Lemos"
        iex> {:ok, date_time} = NaiveDateTime.new(~D[2018-03-23], ~T[13:59:07.005])
        iex> {:ok, money} = Dinheiro.new(12345, :BRL)
        iex> Account.new!(user_name, money, date_time) == %Account{
        ...>    balance: money,
        ...>    transactions: [
        ...>      %AccountTransaction{
        ...>        date_time: date_time,
        ...>        value: money
        ...>      }
        ...>    ],
        ...>    user: user_name
        ...>  }
        true
  """
  def new!(user, balance, date_time) do
    unless is_binary(user),
      do:
        raise(
          ArgumentError,
          message: ":user must be a String"
        )

    raise_if_is_not_dinheiro!(balance, ":balance")

    transaction = AccountTransaction.new!(date_time, balance)

    do_new(user, balance, [transaction])
  end

  defp do_new(user, balance, transactions) do
    %__MODULE__{user: user, balance: balance, transactions: transactions}
  end

  @spec execute(t(), AccountTransaction.t() | [AccountTransaction.t()]) ::
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

  Execute a list of transactions into a new `Account` struct.

    ## Example:

        iex> user_name = "Ramon de Lemos"
        iex> {:ok, money} = Dinheiro.new(0, :BRL)
        iex> {:ok, my_account} = Account.new(user_name, money)
        iex> {:ok, one_value} = Dinheiro.new(1, :BRL)
        iex> plus_one = AccountTransaction.new!(NaiveDateTime.utc_now(), one_value)
        iex> {:ok, my_new_balance} = Account.execute(my_account, [plus_one, plus_one])
        iex> my_new_balance.balance
        %Dinheiro{amount: 200, currency: :BRL}

  """
  def execute(account, transaction) do
    {:ok, execute!(account, transaction)}
  rescue
    e -> {:error, e.message}
  end

  @spec execute!(t(), AccountTransaction.t() | [AccountTransaction.t()]) :: t()
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

  Execute a list of transactions into a new `Account` struct.

    ## Example:

        iex> user_name = "Ramon de Lemos"
        iex> {:ok, money} = Dinheiro.new(0, :BRL)
        iex> {:ok, my_account} = Account.new(user_name, money)
        iex> {:ok, one_value} = Dinheiro.new(1, :BRL)
        iex> plus_one = AccountTransaction.new!(NaiveDateTime.utc_now(), one_value)
        iex> my_new_balance = Account.execute!(my_account, [plus_one, plus_one])
        iex> my_new_balance.balance
        %Dinheiro{amount: 200, currency: :BRL}

  """
  def execute!(account, transaction) when is_list(transaction) == false do
    unless AccountTransaction.is_account_transaction?(transaction),
      do:
        raise(
          ArgumentError,
          message: ":transaction must be AccountTransaction struct"
        )

    execute!(account, [transaction])
  end

  def execute!(account, transactions) do
    raise_if_is_not_account!(account)

    unless is_list_of_account_transaction?(transactions),
      do:
        raise(
          ArgumentError,
          message: ":transactions must be List of AccountTransaction struct"
        )

    new_transactions =
      transactions
      |> remove_zero_transactions()

    if Enum.empty?(new_transactions) do
      account
    else
      do_execute(account, new_transactions)
    end
  end

  defp remove_zero_transactions([]), do: []

  defp remove_zero_transactions([head | tail]) do
    if head.value.amount == 0 do
      remove_zero_transactions(tail)
    else
      [head | remove_zero_transactions(tail)]
    end
  end

  defp do_execute(account, transactions) do
    calc_balance =
      account.transactions
      |> get_transactions_sum!()

    unless Dinheiro.equals?(account.balance, calc_balance),
      do:
        raise(
          AccountError,
          message: "balance must to be equals of the sum of transactions values"
        )

    new_transactions = List.flatten([account.transactions, transactions])

    new_balance =
      new_transactions
      |> get_transactions_sum!()

    unless new_balance.amount >= 0,
      do:
        raise(
          AccountError,
          message: "not enough balance available on the account"
        )

    do_new(account.user, new_balance, new_transactions)
  end

  defp get_transactions_sum!(transactions) do
    transactions
    |> Enum.map(fn x -> x.value end)
    |> Dinheiro.sum!()
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

  defp is_list_of_account_transaction?(list) when is_list(list) do
    Enum.count(list) == count_account_transaction(list)
  end

  defp is_list_of_account_transaction?(_), do: false

  @spec withdraw(t(), Dinheiro.t() | [Dinheiro.t()]) ::
          {:ok, t()} | {:error, String.t()}
  @doc """
  To withdraw money into an new `Account` struct.

  ## Example:
        iex> user_name = "Ramon de Lemos"
        iex> one = Dinheiro.new!(1, :BRL)
        iex> {:ok, account} = Account.new(user_name, Dinheiro.new!(10, :BRL))
        iex> {:ok, account} = Account.withdraw(account, one)
        iex> account.balance == Dinheiro.new!(9, :BRL)
        true
        iex> {:ok, account} = Account.withdraw(account, [one, one])
        iex> account.balance == Dinheiro.new!(7, :BRL)
        true
        iex> Account.withdraw(account, %Dinheiro{amount: 1, currency: :NONE})
        {:error, "'NONE' does not represent an ISO 4217 code"}
  """
  def withdraw(account, money) do
    {:ok, withdraw!(account, money)}
  rescue
    e -> {:error, e.message}
  end

  @spec withdraw!(t(), Dinheiro.t() | [Dinheiro.t()]) :: t()
  @doc """
  To withdraw money into an new `Account` struct.

  ## Example:
        iex> user_name = "Ramon de Lemos"
        iex> one = Dinheiro.new!(1, :BRL)
        iex> account = Account.new!(user_name, Dinheiro.new!(10, :BRL))
        iex> account = Account.withdraw!(account, one)
        iex> account.balance == Dinheiro.new!(9, :BRL)
        true
        iex> account = Account.withdraw!(account, [one, one])
        iex> account.balance == Dinheiro.new!(7, :BRL)
        true
        iex> Account.withdraw!(account, %Dinheiro{amount: 1, currency: :NONE})
        ** (ArgumentError) 'NONE' does not represent an ISO 4217 code
  """
  def withdraw!(account, money) do
    if is_list(money) do
      do_withdraw!(account, money)
    else
      do_withdraw!(account, [money])
    end
  end

  defp do_withdraw!(account, money) do
  end

  @spec deposit(t(), Dinheiro.t() | [Dinheiro.t()]) ::
          {:ok, t()} | {:error, String.t()}
  @doc """
  To deposit money into an new `Account` struct.

  ## Example:
        iex> user_name = "Ramon de Lemos"
        iex> one = Dinheiro.new!(1, :BRL)
        iex> {:ok, account} = Account.new(user_name, Dinheiro.new!(10, :BRL))
        iex> {:ok, account} = Account.deposit(account, one)
        iex> account.balance == Dinheiro.new!(11, :BRL)
        true
        iex> {:ok, account} = Account.deposit(account, [one, one])
        iex> account.balance == Dinheiro.new!(13, :BRL)
        true
        iex> Account.deposit(account, %Dinheiro{amount: 1, currency: :NONE})
        {:error, "'NONE' does not represent an ISO 4217 code"}
  """
  def deposit(account, money) do
    {:ok, deposit!(account, money)}
  rescue
    e -> {:error, e.message}
  end

  @spec deposit!(t(), Dinheiro.t() | [Dinheiro.t()]) :: t()
  @doc """
  To deposit money into an new `Account` struct.

  ## Example:
        iex> user_name = "Ramon de Lemos"
        iex> one = Dinheiro.new!(1, :BRL)
        iex> account = Account.new!(user_name, Dinheiro.new!(10, :BRL))
        iex> account = Account.deposit!(account, one)
        iex> account.balance == Dinheiro.new!(11, :BRL)
        true
        iex> account = Account.deposit!(account, [one, one])
        iex> account.balance == Dinheiro.new!(13, :BRL)
        true
        iex> Account.deposit!(account, %Dinheiro{amount: 1, currency: :NONE})
        ** (ArgumentError) 'NONE' does not represent an ISO 4217 code
  """
  def deposit!(account, money) do
    if is_list(money) do
      do_deposit!(account, money)
    else
      do_deposit!(account, [money])
    end
  end

  defp do_deposit!(account, money) do
  end

  defp raise_if_is_not_valid_money_list!([head | tail]) do
    raise_if_is_not_valid_money!(head)

    if tail != [] do
      raise_if_is_not_valid_money_list!(tail)
    end
  end

  defp raise_if_is_not_valid_money!(money) do
    raise_if_is_not_dinheiro!(money, ":money")

    unless money.amount >= 0,
      do:
        raise(
          ArgumentError,
          message: ":money must be positive"
        )
  end

  defp raise_if_is_not_dinheiro!(money, param_name) do
    unless Dinheiro.is_dinheiro?(money),
      do:
        raise(
          ArgumentError,
          message: "#{param_name} must be a Dinheiro struct"
        )
  end

  defp raise_if_is_not_account!(account) do
    unless is_account?(account),
      do:
        raise(
          ArgumentError,
          message: ":account must be Account struct"
        )
  end
end
