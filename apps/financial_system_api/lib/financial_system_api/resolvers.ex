defmodule FinancialSystemApi.Resolvers do
  @moduledoc false

  alias Ecto.Changeset

  def response({status, payload}) do
    case payload do
      %Changeset{} = changeset ->
        {
          status,
          message: "operation failed",
          changeset: %{
            errors:
              changeset
              |> Changeset.traverse_errors(fn
                {msg, opts} ->
                  String.replace(msg, "%{count}", to_string(opts[:count]))

                msg ->
                  msg
              end),
            action: changeset.action
          }
        }

      _ ->
        {status, payload}
    end
  end
end
