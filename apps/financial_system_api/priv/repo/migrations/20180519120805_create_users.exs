defmodule FinancialSystemApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :username, :string
      add :password_hash, :string
      add :email_verified, :boolean, default: false, null: false
      add :token, :string

      timestamps()
    end

  end
end
