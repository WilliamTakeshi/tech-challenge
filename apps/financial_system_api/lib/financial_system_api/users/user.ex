defmodule FinancialSystemApi.Users.User do
  @moduledoc """
  Module that represents a persistent User.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Comeonin.Bcrypt
  alias FinancialSystemApi.Accounts.Account

  @typedoc """
      Type that represents a persistent User struct with:
      :id as Integer that represents the unique identifier.
      :name as String that represents the name of the user.
      :username as String that represents the nickname of the user.
      :email as String that represents the e-mail of the user.
      :email_verified as Boolean that represents if user e-mail is valid.
      :token as String that is the public identifier of a user to activation.
      :password_hash as String that represents the encrypted user password.
      :accounts as array of FinancialSystemApi.Accounts.Account that contains all user accounts.
  """
  @type t :: %{
          id: Integer.t(),
          name: String.t(),
          username: String.t(),
          email: String.t(),
          email_verified: boolean(),
          token: String.t(),
          password_hash: String.t(),
          accounts: [Account.t()]
        }

  schema "users" do
    field(:name, :string)
    field(:username, :string)
    field(:email, :string)
    field(:email_verified, :boolean, default: false)
    field(:token, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
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
