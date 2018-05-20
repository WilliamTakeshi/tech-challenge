defmodule FinancialSystemApi.UsersTest do
  use FinancialSystemApi.DataCase

  alias FinancialSystemApi.Users

  describe "users" do
    alias FinancialSystemApi.Users.User

    @valid_attrs %{
      email: "some email",
      email_verified: true,
      name: "some name",
      password_hash: "some password_hash",
      token: "some token",
      username: "some username"
    }

    @update_attrs %{
      email: "some updated email",
      email_verified: false,
      name: "some updated name",
      password_hash: "some updated password_hash",
      token: "some updated token",
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
      password_hash: "some password_hash",
      token: "some token",
      username: "some username"
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.email_verified == true
      assert user.name == "some name"
      assert user.password_hash == "some password_hash"
      assert user.token == "some token"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Users.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some updated email"
      assert user.email_verified == false
      assert user.name == "some updated name"
      assert user.password_hash == "some updated password_hash"
      assert user.token == "some updated token"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Users.update_user(user, @invalid_attrs)

      assert user == Users.get_user!(user.id)
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

    test "register_user/1 with valid data creates a user" do
      register_user()
    end

    test "register_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.register_user(@invalid_attrs)
    end

    test "register_user/1 with same email" do
      register_user()
      assert {:error, %Ecto.Changeset{}} = Users.register_user(@unique_attrs)
    end
  end
end
