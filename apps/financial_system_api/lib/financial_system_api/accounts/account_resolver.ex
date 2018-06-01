defmodule FinancialSystemApi.Accounts.AccountResolver do
  @moduledoc false

  alias FinancialSystemApi.Accounts
  alias FinancialSystemApi.FinancialSystemWrapper

  import FinancialSystemApi.Resolvers

  def create(args, %{context: %{current_user: %{id: id}}}) do
    case FinancialSystemWrapper.create(id, 0.0, args.currency) do
      {:ok, account} ->
        account
        |> Accounts.create_account()
        |> response()

      {:error, reason} ->
        {:error, reason}
    end
  rescue
    e -> {:error, e.message}
  end

  def create(_args, _info) do
    {:error, "not authorized"}
  end

  def transfer(args, %{context: %{current_user: %{id: id}}}) do
    from = Accounts.get_account!(args.from)

    if from.user_id == id do
      to = Accounts.get_account!(args.to)

      if from.id == to.id do
        {:error, "you can not transfer money to same account"}
      else
        case FinancialSystemWrapper.transfer(from, to, args.value) do
          {:ok, result} ->
            case Accounts.update_transfer(from, result.from, to, result.to) do
              {:ok, {:ok, f, t}} ->
                {:ok, %{from: f, to: t}}

              {:error, reason} ->
                {:error, reason}
            end

          {:error, reason} ->
            {:error, reason}
        end
      end
    else
      {:error, "the origin account does not belongs to you"}
    end
  rescue
    e -> {:error, e.message}
  end

  def transfer(_args, _info) do
    {:error, "not authorized"}
  end

  def withdraw(args, %{context: %{current_user: %{id: id}}}) do
    from = Accounts.get_account!(args.from)

    if from.user_id == id do
      case FinancialSystemWrapper.withdraw(from, args.value) do
        {:ok, f} -> Accounts.update_account(from, f)
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, "this account does not belongs to you"}
    end
  rescue
    e -> {:error, e.message}
  end

  def withdraw(_args, _info) do
    {:error, "not authorized"}
  end
end
