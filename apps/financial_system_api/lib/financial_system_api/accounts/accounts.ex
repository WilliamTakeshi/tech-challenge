defmodule FinancialSystemApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias FinancialSystemApi.Repo

  alias FinancialSystemApi.Accounts.Account

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
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
  def get_account!(id), do: Repo.get!(Account, id)

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
    |> Account.changeset(attrs)
    |> Repo.update()
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

  alias FinancialSystemApi.Accounts.AccountTransaction

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
end
