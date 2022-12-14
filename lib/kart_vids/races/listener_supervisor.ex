defmodule KartVids.Races.ListenerSupervisor do
  @moduledoc false
  use Parent.GenServer
  require Logger
  alias KartVids.Content
  alias KartVids.Races.Listener

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(arg), do: Parent.GenServer.start_link(__MODULE__, arg, name: __MODULE__)

  @impl GenServer
  @spec init(any) :: {:ok, nil}
  def init(_) do
    send(self(), :start_locations)
    {:ok, nil}
  end

  @delay_minutes 1
  # 5 minutes
  @delay @delay_minutes * 60 * 1000

  @impl Parent.GenServer
  def handle_stopped_children(stopped_children, state) do
    Logger.info("Websocket connection unstable, will retry connecting in #{@delay_minutes} minutes #{inspect(stopped_children)}")
    Process.send_after(self(), {:restart, stopped_children}, @delay)
    {:noreply, state}
  end

  def handle_info({:restart, stopped_children}, state) do
    Logger.info("Attempting to restoring websocket connection #{inspect(stopped_children)}")
    Parent.return_children(stopped_children)
    {:noreply, state}
  end

  def handle_info({:start_location, location}, state) do
    case Listener.whereis(location) do
      nil ->
        start_location(location)

      _pid ->
        nil
    end

    {:noreply, state}
  end

  def handle_info(:start_locations, state) do
    Logger.info("Starting location websocket connections...")

    locations = Content.list_locations()

    results =
      for location <- locations do
        start_location(location)
      end

    if Enum.all?(results, & &1) do
      Logger.info("All done starting location listeners!")
    else
      Logger.info("Some locations did not start successfully...")
    end

    {:noreply, state}
  end

  def handle_info({:ack, _, {:ok, _}}, state) do
    {:noreply, state}
  end

  def handle_info(message, state) do
    super(message, state)
  end

  @retry_minutes 1
  @retry_minutes_in_ms @retry_minutes * 60 * 1000

  defp start_location(location) do
    child = Listener.child_spec(location)

    try do
      case Parent.start_child(child) do
        {:ok, pid} ->
          Logger.info("Location #{location.name} booted and linked to #{inspect(pid)}")

        {:error, {:already_started, _pid}} ->
          nil

        other ->
          Logger.warn("Start child did not succeed, will try again in #{@retry_minutes} minute(s), cause: #{inspect(other)}")
          Process.send_after(self(), {:start_location, location}, @retry_minutes_in_ms)
      end

      true
    rescue
      e ->
        Logger.info("Trouble with starting location #{location.name} (#{location.id}) (will try again in #{@delay_minutes} minute(s))")
        Logger.warn("Rescued Failure starting location: #{inspect(e)} (#{inspect(self())})")
        Process.send_after(self(), {:start_location, location}, @delay)

        false
    end
  end
end
