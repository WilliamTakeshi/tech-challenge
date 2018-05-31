defmodule FinancialSystemApiWeb.GraphqlAccountTest do
  use FinancialSystemApiWeb.ConnCase

  alias FinancialSystemApi.Accounts

  @user %{
    email: "some@email",
    name: "some name",
    password: "some password",
    username: "some username"
  }

  @another_user %{
    email: "anotheruser@email",
    name: "another name",
    password: "another password",
    username: "another username"
  }

  @create_query """
  mutation CreateAccount($currency: String!) {
    createAccount(currency: $currency) {
      id
      , amount
      , currency
      , user {
        id
      }
    }
  }
  """

  @brl_account %{amount: 0.0, currency: "BRL", user_id: nil}
  @usd_account %{amount: 0.0, currency: "USD", user_id: nil}

  @transfer_query """
  mutation Transfer($from: ID!, $to: ID!, $value: Float!) {
    transfer(from: $from, to: $to, value: $value){
      from {
        id
        , amount
        , currency
      }
      , to {
        id
        , amount
        , currency
      }
    }
  }
  """

  @withdraw_query """
  mutation Withdraw($from: ID!, $value: Float!) {
    withdraw(from: $from, value: $value){
      id
      , amount
      , currency
      , user {
        id
      }
    }
  }
  """

  setup do
    user = build_an_activated_user(@user)
    another_user = build_an_activated_user(@another_user)

    {:ok, brl_account} =
      Accounts.create_account(%{@brl_account | user_id: user.id})

    {:ok, usd_account} =
      Accounts.create_account(%{@usd_account | user_id: user.id})

    {:ok,
     %{
       user: user,
       brl_account: brl_account,
       usd_account: usd_account,
       another_user: another_user
     }}
  end

  test "create an account to an authenticated user", %{conn: conn, user: user} do
    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @create_query,
        variables: %{
          currency: "BRL"
        }
      )

    assert response["data"]["createAccount"]["currency"] == "BRL"
    assert response["data"]["createAccount"]["amount"] == 0.0
    assert response["data"]["createAccount"]["user"]["id"] == "#{user.id}"
  end

  test "create an account to an authenticated user with an invalid currency", %{
    conn: conn
  } do
    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @create_query,
        variables: %{
          currency: "NONE"
        }
      )

    assert response ==
             graphql_error_message(
               "createAccount",
               "'NONE' does not represent an ISO 4217 code"
             )
  end

  test "create an account to a not authenticated user", %{conn: conn} do
    response =
      conn
      |> graphql_query(
        query: @create_query,
        variables: %{
          currency: "BRL"
        }
      )

    assert response == graphql_error_message("createAccount", "not authorized")
  end

  test "transfer money between accounts of the authenticated user", %{
    conn: conn,
    user: user,
    brl_account: brl_account
  } do
    principal_account = List.first(user.accounts)

    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @transfer_query,
        variables: %{
          from: principal_account.id,
          to: brl_account.id,
          value: 10.5
        }
      )

    assert response["data"]["transfer"]["from"]["id"] ==
             "#{principal_account.id}"

    assert response["data"]["transfer"]["from"]["currency"] == "BRL"
    assert response["data"]["transfer"]["from"]["amount"] == 989.5
    assert response["data"]["transfer"]["to"]["id"] == "#{brl_account.id}"
    assert response["data"]["transfer"]["to"]["currency"] == "BRL"
    assert response["data"]["transfer"]["to"]["amount"] == 10.5
  end

  test "transfer money from an empty account", %{
    conn: conn,
    user: user,
    brl_account: brl_account
  } do
    principal_account = List.first(user.accounts)

    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @transfer_query,
        variables: %{
          from: brl_account.id,
          to: principal_account.id,
          value: 10.5
        }
      )

    assert response ==
             graphql_error_message(
               "transfer",
               "not enough balance available on the account"
             )
  end

  test "transfer money between different currency accounts", %{
    conn: conn,
    user: user,
    usd_account: usd_account
  } do
    principal_account = List.first(user.accounts)

    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @transfer_query,
        variables: %{
          from: principal_account.id,
          to: usd_account.id,
          value: 10.5
        }
      )

    assert response ==
             graphql_error_message(
               "transfer",
               "currency :BRL different of :USD"
             )
  end

  test "transfer money from a different user account", %{
    conn: conn,
    user: user,
    another_user: another_user
  } do
    user_account = List.first(user.accounts)
    another_user_account = List.first(another_user.accounts)

    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @transfer_query,
        variables: %{
          from: another_user_account.id,
          to: user_account.id,
          value: 10.5
        }
      )

    assert response ==
             graphql_error_message(
               "transfer",
               "the origin account does not belongs to you"
             )
  end

  test "transfer with a not authenticated user", %{conn: conn} do
    response =
      conn
      |> graphql_query(
        query: @transfer_query,
        variables: %{
          from: 1,
          to: 2,
          value: 10.5
        }
      )

    assert response == graphql_error_message("transfer", "not authorized")
  end

  test "transfer money to same account", %{conn: conn, user: user} do
    user_account = List.first(user.accounts)

    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @transfer_query,
        variables: %{
          from: user_account.id,
          to: user_account.id,
          value: 10.5
        }
      )

    assert response ==
             graphql_error_message(
               "transfer",
               "you can not transfer money to same account"
             )
  end

  test "withdraw money from an account of the authenticated user", %{
    conn: conn,
    user: user
  } do
    principal_account = List.first(user.accounts)

    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @withdraw_query,
        variables: %{
          from: principal_account.id,
          value: 10.5
        }
      )

    assert response["data"]["withdraw"]["id"] == "#{principal_account.id}"
    assert response["data"]["withdraw"]["amount"] == 989.5
    assert response["data"]["withdraw"]["currency"] == "BRL"
    assert response["data"]["withdraw"]["user"]["id"] == "#{user.id}"
  end

  test "withdraw with a not authenticated user", %{conn: conn} do
    response =
      conn
      |> graphql_query(
        query: @withdraw_query,
        variables: %{
          from: 1,
          value: 10.5
        }
      )

    assert response == graphql_error_message("withdraw", "not authorized")
  end

  test "withdraw money from a different user account", %{
    conn: conn,
    another_user: another_user
  } do
    another_user_account = List.first(another_user.accounts)

    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @withdraw_query,
        variables: %{
          from: another_user_account.id,
          value: 10.5
        }
      )

    assert response ==
             graphql_error_message(
               "withdraw",
               "this account does not belongs to you"
             )
  end

  test "withdraw negative value from an account of the authenticated user", %{
    conn: conn,
    user: user
  } do
    principal_account = List.first(user.accounts)

    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @withdraw_query,
        variables: %{
          from: principal_account.id,
          value: -10.5
        }
      )

    assert response ==
             graphql_error_message(
               "withdraw",
               ":money must be positive"
             )
  end

  test "withdraw a value greater than the balance", %{
    conn: conn,
    user: user
  } do
    principal_account = List.first(user.accounts)

    response =
      conn
      |> authenticate_user(@user)
      |> graphql_query(
        query: @withdraw_query,
        variables: %{
          from: principal_account.id,
          value: 1_000.01
        }
      )

    assert response ==
             graphql_error_message(
               "withdraw",
               "not enough balance available on the account"
             )
  end
end
