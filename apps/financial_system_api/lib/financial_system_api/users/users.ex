defmodule FinancialSystemApi.Users do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias FinancialSystemApi.Repo
  alias FinancialSystemApi.Users.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Return `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id) do
    get_user!(id)
  rescue
    _e -> nil
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Register a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single user.

  Return `nil` if the User does not exist.

  ## Examples

      iex> find(%{id: 123})
      %User{}

      iex> find(%{id: 256})
      nil

      iex> find(%{token: "abc"})
      %User{}

      iex> find(%{token: "def"})
      nil

      iex> find(%{username: "valid username"})
      %User{}

      iex> find(%{username: "invalid username"})
      nil

      iex> find(%{email: "valid@email"})
      %User{}

      iex> find(%{email: "invalid@username"})
      nil

  """
  def find(%{id: id}) do
    get_user(id)
  end

  def find(%{token: token}) do
    Repo.get_by(User, token: token)
  end

  def find(%{username: username}) do
    Repo.get_by(User, username: username)
  end

  def find(%{email: email}) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Activate a user.

  ## Examples

      iex> activate_user(%{field: value})
      {:ok, %User{}}

      iex> activate_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def activate_user(%User{} = user) do
    user
    |> User.put_verified_changeset(%{})
    |> Repo.update()
  end
end
