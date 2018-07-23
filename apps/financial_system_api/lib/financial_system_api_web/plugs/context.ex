defmodule FinancialSystemApiWeb.Plugs.Context do
  @moduledoc """
  Module responsible to assign the current user into a valid request.
  """

  @behaviour Plug

  import Plug.Conn

  alias Guardian.Plug, as: GuardianPlug

  def init(opts), do: opts

  def call(conn, _) do
    case GuardianPlug.current_resource(conn) do
      nil ->
        conn

      user ->
        put_private(conn, :absinthe, %{context: %{current_user: user}})
    end
  end
end
