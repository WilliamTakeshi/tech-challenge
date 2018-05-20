defmodule FinancialSystemApi.Users.User do
  @moduledoc false

  use Ecto.Schema
  alias Comeonin.Bcrypt
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
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [
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

  @doc false
  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :username, :password])
    |> validate_required([:name, :email, :username, :password])
    |> unique_constraint(:email)
    |> put_pass_hash()
    |> put_not_verified()
    |> put_token()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end

  defp put_not_verified(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :email_verified, false)

      _ ->
        changeset
    end
  end

  defp put_token(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :token, SecureRandom.urlsafe_base64())

      _ ->
        changeset
    end
  end
end
