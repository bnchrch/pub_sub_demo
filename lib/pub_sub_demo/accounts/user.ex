defmodule PubSubDemo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :name, :string
    field :payment_plan, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :payment_plan])
    |> validate_required([:name, :payment_plan])
  end
end
