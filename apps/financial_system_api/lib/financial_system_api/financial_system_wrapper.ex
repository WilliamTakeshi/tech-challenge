defmodule FinancialSystemApi.FinancialSystemWrapper do
  @moduledoc false

  def validate_currency(args) do
    case Dinheiro.new(args.amount, args.currency) do
      {:ok, value} -> {:ok, value.currency |> Atom.to_string()}
      {:error, reason} -> {:error, reason}
    end
  end
end
