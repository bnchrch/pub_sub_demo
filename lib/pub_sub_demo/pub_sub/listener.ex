defmodule PubSubDemo.PubSub.Listener do
  use GenServer

  require Logger

  import Poison, only: [decode!: 1]

  @moduledoc """
  Subscribes to a set of given topics at startup and listens for specific events
  """

  @doc """
  Initialize the activity GenServer
  """
  @spec start_link([String.t], [any])  :: {:ok, pid}
  def start_link(channel, otp_opts \\ []), do: GenServer.start_link(__MODULE__, channel, otp_opts)

  @doc """
  When the GenServer starts subscribe to the given channel
  """
  @spec init([String.t])  :: {:ok, []}
  def init(channel) do
    Logger.debug("Starting #{ __MODULE__ } with channel subscription: #{channel}")
    pg_config = PubSubDemo.Repo.config()
    {:ok, pid} = Postgrex.Notifications.start_link(pg_config)
    {:ok, ref} = Postgrex.Notifications.listen(pid, channel)
    {:ok, {pid, channel, ref}}
  end

  @doc """
  Listen for changes in the users table
  """
  def handle_info({:notification, _pid, _ref, "users_changes", payload}, _state) do
    payload
    |> decode!()
    |> handle_user_changes()

    {:noreply, :event_handled}
  end

  def handle_info(_, _state), do: {:noreply, :event_received}

  @doc """
  Listen for new users and log when created
  """
  def handle_user_changes(%{
    "type" => "INSERT",
    "new_row_data" => %{
      "name" => name
    }
  }) do
    IO.puts("New user created with the name: #{name}")
  end

  @doc """
  Listen anf log when users change their payment plan
  """
  def handle_user_changes(%{
    "type" => "UPDATE",
    "old_row_data" => %{
      "name" => old_name,
      "payment_plan" => old_payment_plan,
    },
    "new_row_data" => %{
      "name" => new_name,
      "payment_plan" => new_payment_plan,
    },
  }) when old_payment_plan != new_payment_plan do
    IO.puts("#{new_name} updated their payment plan from #{old_payment_plan} to #{new_payment_plan}")
  end

  def handle_user_changes(payload), do: nil
end
