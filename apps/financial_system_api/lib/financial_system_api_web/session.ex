defmodule FinancialSystemApiWeb.Session do
  @moduledoc false

  alias Comeonin.Bcrypt

  def authenticate(params, repository) do
    user = repository.find(%{email: String.downcase(params.email)})

    if user do
      if user.email_verified do
        case check_password(user, params.password) do
          true -> {:ok, user}
          _ -> {:error, "incorrect login credentials"}
        end
      else
        {:error, "e-mail not verified"}
      end
    else
      {:error, "not found"}
    end
  end

  defp check_password(user, password) do
    case user do
      nil -> false
      _ -> Bcrypt.checkpw(password, user.password_hash)
    end
  end
end
