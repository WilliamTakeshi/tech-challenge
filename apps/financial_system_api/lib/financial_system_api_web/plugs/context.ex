defmodule FinancialSystemApiWeb.Plugs.Context do
  @moduledoc false

  @behaviour Plug

  alias Guardian.Plug, as: GuardianPlug

  import Plug.Conn

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
