defmodule FinancialSystemApi.UsersTest do
  use FinancialSystemApi.DataCase

  alias FinancialSystemApi.Users

  describe "users" do
    alias FinancialSystemApi.Users.User

    @valid_attrs %{
      email: "some@email",
      email_verified: true,
      name: "some name",
      password: "some password",
      username: "some username"
    }

    @update_attrs %{
      email: "some.updated@email",
      email_verified: false,
      name: "some updated name",
      username: "some updated username"
    }

    @invalid_attrs %{
      email: nil,
      email_verified: nil,
      name: nil,
      password_hash: nil,
      token: nil,
      username: nil
    }

    @unique_attrs %{
      email: "some@email",
      email_verified: false,
      name: "some name",
      password: "some password",
      username: "some username"
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.register_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [%{user | password: nil}]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == %{user | password: nil}
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Users.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some.updated@email"
      assert user.email_verified == false
      assert user.name == "some updated name"
      assert user.password_hash != nil
      assert user.token != nil
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Users.update_user(user, @invalid_attrs)

      assert %{user | password: nil} == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end

    defp register_user do
      assert {:ok, %User{} = user} = Users.register_user(@unique_attrs)
      assert user.email == "some@email"
      assert user.email_verified == false
      assert user.name == "some name"
      assert user.username == "some username"
      assert user.password_hash != nil
      assert user.token != nil
    end

    test "register_user/1 with valid data register a user" do
      register_user()
    end

    test "register_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.register_user(@invalid_attrs)
    end

    test "register_user/1 with same email" do
      register_user()
      {:error, changeset} = Users.register_user(@unique_attrs)
      assert %{email: ["email is already taken"]} = errors_on(changeset)
    end

    test "activate_user/1 with valid user data" do
      user = user_fixture()
      {:ok, user_activated} = Users.activate_user(user)
      assert user_activated.email_verified == true
    end

    test "activate_user/1 with invalid user data" do
      assert {:error, %Ecto.Changeset{}} = Users.activate_user(%User{})
    end

    test "find/1 with %{id: id}" do
      user = user_fixture()
      assert Users.find(%{id: user.id}) == %{user | password: nil}
    end

    test "find/1 with %{token: token}" do
      user = user_fixture()
      assert Users.find(%{token: user.token}) == %{user | password: nil}
    end

    test "find/1 with %{username: username}" do
      user = user_fixture()
      assert Users.find(%{username: user.username}) == %{user | password: nil}
    end

    test "find/1 with %{email: email}" do
      user = user_fixture()
      assert Users.find(%{email: user.email}) == %{user | password: nil}
    end
  end
end
