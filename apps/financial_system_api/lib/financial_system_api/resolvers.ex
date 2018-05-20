defmodule FinancialSystemApi.Resolvers do
  @moduledoc false
  def response({status, payload}) do
    case payload do
      %Ecto.Changeset{} = changeset ->
        {
          status,
          message: "operation failed",
          changeset: %{
            errors: changeset
            |> Ecto.Changeset.traverse_errors(fn
              {msg, opts} -> String.replace(msg, "%{count}", to_string(opts[:count]))
              msg -> msg
            end),
            action: changeset.action
          }
        }
      _ -> {status, payload}
    end
  end
end