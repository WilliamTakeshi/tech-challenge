defmodule FinancialSystemApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Adapters.SQL
  alias Ecto.Changeset
  alias FinancialSystemApi.Repo
  alias FinancialSystemApi.Accounts.Account
  alias FinancialSystemApi.Accounts.AccountTransaction
  alias FinancialSystemApi.Accounts.AccountTransactionOneDay

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Account
    |> Repo.all()
    |> Repo.preload(:transactions)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id),
    do: Account |> Repo.get!(id) |> Repo.preload(:transactions)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Changeset.cast_assoc(
      :transactions,
      with: &AccountTransaction.changeset/2
    )
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Repo.preload(:transactions)
    |> Account.changeset(attrs)
    |> Changeset.put_assoc(:transactions, attrs.transactions)
    |> Repo.update()
  end

  def update_transfer(%Account{} = from, from_attrs, %Account{} = to, to_attrs) do
    Repo.transaction(fn ->
      with {:ok, f} <- update_account(from, from_attrs),
           {:ok, t} <- update_account(to, to_attrs) do
        {:ok, f, t}
      else
        {:error, reason} ->
          Repo.rollback(reason)
          {:error, reason}
      end
    end)
  end

  @doc """
  Deletes a Account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{source: %Account{}}

  """
  def change_account(%Account{} = account) do
    Account.changeset(account, %{})
  end

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%AccountTransaction{}, ...]

  """
  def list_transactions do
    Repo.all(AccountTransaction)
  end

  @doc """
  Gets a single account_transaction.

  Raises `Ecto.NoResultsError` if the Account transaction does not exist.

  ## Examples

      iex> get_account_transaction!(123)
      %AccountTransaction{}

      iex> get_account_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account_transaction!(id), do: Repo.get!(AccountTransaction, id)

  @doc """
  Creates a account_transaction.

  ## Examples

      iex> create_account_transaction(%{field: value})
      {:ok, %AccountTransaction{}}

      iex> create_account_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account_transaction(attrs \\ %{}) do
    %AccountTransaction{}
    |> AccountTransaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account_transaction.

  ## Examples

      iex> update_account_transaction(account_transaction, %{field: new_value})
      {:ok, %AccountTransaction{}}

      iex> update_account_transaction(account_transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_transaction(
        %AccountTransaction{} = account_transaction,
        attrs
      ) do
    account_transaction
    |> AccountTransaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a AccountTransaction.

  ## Examples

      iex> delete_account_transaction(account_transaction)
      {:ok, %AccountTransaction{}}

      iex> delete_account_transaction(account_transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account_transaction(%AccountTransaction{} = account_transaction) do
    Repo.delete(account_transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account_transaction changes.

  ## Examples

      iex> change_account_transaction(account_transaction)
      %Ecto.Changeset{source: %AccountTransaction{}}

  """
  def change_account_transaction(%AccountTransaction{} = account_transaction) do
    AccountTransaction.changeset(account_transaction, %{})
  end

  def balance_report(:day, date) do
    query = from(r in AccountTransactionOneDay)

    query =
      if date != nil do
        from(
          r in query,
          where: r.transaction_day == type(^date, :date)
        )
      else
        query
      end

    Repo.all(query)
  end

  def balance_report(:month, date) do
    query = from(r in AccountTransactionOneDay)

    query =
      if date != nil do
        from(
          r in query,
          where:
            fragment(
              "date_trunc('month', ?)",
              r.transaction_day
            ) ==
              fragment(
                "date_trunc('month', ?)",
                type(^date, :date)
              )
        )
      else
        query
      end

    query =
      from(
        r in query,
        group_by: [
          fragment("date_trunc('month', ?)", r.transaction_day),
          r.currency
        ],
        select: %AccountTransactionOneDay{
          date:
            type(
              fragment("date_trunc('month', ?)", r.transaction_day),
              :naive_datetime
            ),
          currency: r.currency,
          credit: sum(r.credit),
          debit: sum(r.debit)
        }
      )

    Repo.all(query)
  end

  def balance_report(:year, date) do
    query = from(r in AccountTransactionOneDay)

    query =
      if date != nil do
        from(
          r in query,
          where:
            fragment(
              "date_trunc('year', ?)",
              r.transaction_day
            ) ==
              fragment(
                "date_trunc('year', ?)",
                type(^date, :date)
              )
        )
      else
        query
      end

    query =
      from(
        r in query,
        group_by: [
          fragment("date_trunc('year', ?)", r.transaction_day),
          r.currency
        ],
        select: %AccountTransactionOneDay{
          date:
            type(
              fragment("date_trunc('year', ?)", r.transaction_day),
              :naive_datetime
            ),
          currency: r.currency,
          credit: sum(r.credit),
          debit: sum(r.debit)
        }
      )

    Repo.all(query)
  end

  def balance_report(:total, _date) do
    query = from(r in AccountTransactionOneDay)

    query =
      from(
        r in query,
        group_by: r.currency,
        select: %AccountTransactionOneDay{
          date:
            type(
              fragment("current_timestamp"),
              :naive_datetime
            ),
          currency: r.currency,
          credit: sum(r.credit),
          debit: sum(r.debit)
        }
      )

    Repo.all(query)
  end

  def idle_report do
    query =
      from(
        l in "last_user_transaction",
        where:
          l.last_transaction <= fragment("current_date - interval '1' month"),
        select: %{
          date:
            type(
              fragment("current_timestamp"),
              :naive_datetime
            ),
          count: count(l.user_id)
        }
      )

    Repo.one(query)
  end

  def update_transactions_aggregations do
    {:ok, _} =
      Repo
      |> SQL.query("select do_transactions_aggregations()")

    {:ok, _} =
      Repo
      |> SQL.query("select do_last_user_transactions()")

    :ok
  end
end
