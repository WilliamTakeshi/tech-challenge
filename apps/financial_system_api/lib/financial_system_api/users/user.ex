defmodule FinancialSystemApi.Users.User do
  @moduledoc false

  use Ecto.Schema
  alias Comeonin.Bcrypt
  alias FinancialSystemApi.Accounts.Account
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:email_verified, :boolean, default: false)
    field(:name, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:token, :string)
    field(:username, :string)
    has_many(:accounts, Account)

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :username], [:password])
    |> validate_email()
    |> validate_required([:name, :email, :username])
    |> unique_constraint(:email, message: "email is already taken")
    |> unique_constraint(:username, message: "username is already taken")
    |> put_pass_hash()
  end

  @doc false
  def registration_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required([:password])
    |> put_not_verified()
    |> put_token()
    |> put_pass_hash()
  end

  defp validate_email(struct) do
    struct
    |> validate_format(:email, ~r/@/)
  end

  @doc false
  def put_verified_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> cast(params, [])
    |> put_verified()
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

  defp put_verified(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :email_verified, true)

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
