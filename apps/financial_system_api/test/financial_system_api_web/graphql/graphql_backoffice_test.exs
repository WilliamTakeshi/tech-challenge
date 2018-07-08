defmodule FinancialSystemApiWeb.GraphqlBackofficeTest do
  use FinancialSystemApiWeb.ConnCase

  alias FinancialSystemApi.Accounts

  @user %{
    email: "some@email",
    name: "some name",
    password: "some password",
    username: "some username"
  }

  @one_day 86_400

  @balance_report_query """
  query Backoffice($by: BalanceType!, $date: Date) {
    balanceReport(by: $by, date: $date) {
      credit
      , debit
      , currency
      , date
    }
  }
  """

  setup do
    user = build_an_activated_user(@user)

    # Para evitar problemas nos cálculos em períodos de mudança de mês/ano
    # mantive todas as transações no mesmo mês da última transação
    # da conta principal.

    account = List.first(user.accounts)
    last_transaction = List.first(account.transactions)

    handle_date = last_transaction.date_time

    edge_date =
      NaiveDateTime.add(
        last_transaction.date_time,
        @one_day * 2
      )

    {edge_day, middle_day} =
      if handle_date.month == edge_date.month do
        {
          edge_date,
          NaiveDateTime.add(
            handle_date,
            @one_day
          )
        }
      else
        {
          NaiveDateTime.add(
            handle_date,
            @one_day * -2
          ),
          NaiveDateTime.add(
            handle_date,
            @one_day * -1
          )
        }
      end

    transient_account = %{
      amount: 0.00,
      currency: "BRL",
      user_id: user.id,
      transactions: [
        %{date_time: edge_day, value: 0.01},
        %{date_time: middle_day, value: -0.01}
      ]
    }

    {:ok, brl_account} = Accounts.create_account(transient_account)

    {:ok,
     %{
       user: user,
       brl_account: brl_account,
       handle_day: handle_date,
       middle_day: middle_day,
       edge_day: edge_day
     }}
  end

  test "run balance report to a not authenticated user", %{conn: conn} do
    response =
      conn
      |> graphql_query(
        query: @balance_report_query,
        variables: %{
          by: "DAY"
        }
      )

    assert response == graphql_error_message("balanceReport", "not authorized")
  end

  test "run balance report to edge day", %{conn: conn} do
    response =
      conn
      |> graphql_query(
        query: @balance_report_query,
        variables: %{
          by: "DAY"
        }
      )

    assert response == graphql_error_message("balanceReport", "not authorized")
  end
end
