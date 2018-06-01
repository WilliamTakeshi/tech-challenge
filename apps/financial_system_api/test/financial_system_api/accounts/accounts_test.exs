defmodule FinancialSystemApi.AccountsTest do
  use FinancialSystemApi.DataCase

  alias FinancialSystemApi.Accounts
  alias FinancialSystemApi.Users

  describe "accounts" do
    alias FinancialSystemApi.Accounts.Account

    @valid_user_attrs %{
      email: "some@email",
      email_verified: true,
      name: "some name",
      password: "some password",
      username: "some username"
    }

    @valid_attrs %{amount: 42.0, currency: "some currency", transactions: []}
    @update_attrs %{
      amount: 43.0,
      currency: "some updated currency",
      transactions: []
    }
    @invalid_attrs %{amount: nil, currency: nil, transactions: nil}

    def account_fixture(_attrs \\ %{}) do
      {:ok, account} =
        get_valid_attrs()
        |> Enum.into(@valid_attrs)
        |> Accounts.create_account()

      account
    end

    def get_valid_attrs do
      {:ok, user} =
        @valid_user_attrs
        |> Users.register_user()

      %{amount: 42.0, currency: "some currency", user_id: user.id}
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Accounts.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == %{account | transactions: []}
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} =
               Accounts.create_account(get_valid_attrs())

      assert account.amount == 42.0
      assert account.currency == "some currency"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, account} = Accounts.update_account(account, @update_attrs)
      assert %Account{} = account
      assert account.amount == 43.0
      assert account.currency == "some updated currency"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_account(account, @invalid_attrs)

      assert %{account | transactions: []} == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_account!(account.id)
      end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end

  describe "transactions" do
    alias FinancialSystemApi.Accounts.AccountTransaction

    @valid_attrs %{date_time: ~N[2010-04-17 14:00:00.000000], value: 42.0}
    @update_attrs %{date_time: ~N[2011-05-18 15:01:01.000000], value: 43.0}
    @invalid_attrs %{date_time: nil, value: nil}

    def account_transaction_fixture(attrs \\ %{}) do
      {:ok, account_transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_account_transaction()

      account_transaction
    end

    test "list_transactions/0 returns all transactions" do
      account_transaction = account_transaction_fixture()
      assert Accounts.list_transactions() == [account_transaction]
    end

    test "get_account_transaction!/1 returns the account_transaction with given id" do
      account_transaction = account_transaction_fixture()

      assert Accounts.get_account_transaction!(account_transaction.id) ==
               account_transaction
    end

    test "create_account_transaction/1 with valid data creates a account_transaction" do
      assert {:ok, %AccountTransaction{} = account_transaction} =
               Accounts.create_account_transaction(@valid_attrs)

      assert account_transaction.date_time == ~N[2010-04-17 14:00:00.000000]
      assert account_transaction.value == 42.0
    end

    test "create_account_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_account_transaction(@invalid_attrs)
    end

    test "update_account_transaction/2 with valid data updates the account_transaction" do
      account_transaction = account_transaction_fixture()

      assert {:ok, account_transaction} =
               Accounts.update_account_transaction(
                 account_transaction,
                 @update_attrs
               )

      assert %AccountTransaction{} = account_transaction
      assert account_transaction.date_time == ~N[2011-05-18 15:01:01.000000]
      assert account_transaction.value == 43.0
    end

    test "update_account_transaction/2 with invalid data returns error changeset" do
      account_transaction = account_transaction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_account_transaction(
                 account_transaction,
                 @invalid_attrs
               )

      assert account_transaction ==
               Accounts.get_account_transaction!(account_transaction.id)
    end

    test "delete_account_transaction/1 deletes the account_transaction" do
      account_transaction = account_transaction_fixture()

      assert {:ok, %AccountTransaction{}} =
               Accounts.delete_account_transaction(account_transaction)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_account_transaction!(account_transaction.id)
      end
    end

    test "change_account_transaction/1 returns a account_transaction changeset" do
      account_transaction = account_transaction_fixture()

      assert %Ecto.Changeset{} =
               Accounts.change_account_transaction(account_transaction)
    end
  end
end
