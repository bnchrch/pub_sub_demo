defmodule PubSubDemo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :payment_plan, :string

      timestamps()
    end

  end
end
