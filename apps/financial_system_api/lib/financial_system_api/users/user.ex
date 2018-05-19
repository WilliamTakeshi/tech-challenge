defmodule FinancialSystemApi.Users.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:email_verified, :boolean, default: false)
    field(:name, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:token, :string)
    field(:username, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :username,
      :password_hash,
      :email_verified,
      :token
    ])
    |> validate_required([
      :name,
      :email,
      :username,
      :password_hash,
      :email_verified,
      :token
    ])
  end
end
