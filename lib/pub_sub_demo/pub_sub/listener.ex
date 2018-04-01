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
  Listen for changes
  """
  def handle_info({:notification, _pid, _ref, "users_changes", payload}, _state) do
    payload
    |> decode!()
    |> IO.inspect()

    {:noreply, :event_handled}
  end

  def handle_info(_, _state), do: {:noreply, :event_received}
end
