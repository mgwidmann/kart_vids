defmodule KartVids.Races.ListenerSupervisor do
  @moduledoc false
  use Parent.GenServer
  use EnumType
  require Logger
  alias KartVids.Races.ListenerSupervisor.Status
  alias KartVids.Content
  alias KartVids.Content.Location
  alias KartVids.Races.Listener

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(arg), do: Parent.GenServer.start_link(__MODULE__, arg, name: __MODULE__)

  @listener_status_check_mins 1

  @impl GenServer
  @spec init(any) :: {:ok, %{statuses: %{}}}
  def init(_) do
    send(self(), :start_locations)
    :timer.send_interval(:timer.minutes(@listener_status_check_mins), :check_listeners)
    {:ok, %{statuses: %{}}}
  end

  def listener_status(%Location{id: id}), do: listener_status(id)

  def listener_status(id) when is_number(id) do
    GenServer.call(__MODULE__, {:listener_status, id})
  end

  defenum Status do
    value(Online, :online)
    value(NotResponding, :not_responding)
    value(Offline, :offline)

    default(Offline)
  end

  alias Status

  @delay_minutes 1
  # 5 minutes
  @delay @delay_minutes * 60 * 1000

  @impl Parent.GenServer
  def handle_stopped_children(stopped_children, state) do
    Logger.info("Websocket connection unstable, will retry connecting in #{@delay_minutes} minutes #{inspect(stopped_children)}")
    Process.send_after(self(), {:restart, stopped_children}, @delay)
    {:noreply, state}
  end

  @impl true
  def handle_call({:listener_status, id}, _from, state = %{statuses: statuses}) do
    {:reply, Map.get(statuses, id, Status.Offline), state}
  end

  def handle_info(:check_listeners, state) do
    locations = Content.list_locations()

    statuses =
      for location <- locations, into: %{} do
        {location.id, get_location_status(location)}
      end

    {:noreply, %{state | statuses: statuses}}
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
      # Initial check since timer will invoke after timeout
      send(self(), :check_listeners)
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

  defp get_location_status(location) do
    pid = Listener.whereis(location)

    cond do
      is_nil(pid) || !Process.alive?(pid) -> Status.Offline
      !Listener.ping(pid) -> Status.NotResponding
      true -> Status.Online
    end
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

      status = get_location_status(location)

      if status != Status.Online do
        Logger.warn("Location #{location.name} (#{location.id}) started successfully but then refused to respond to pings, got status: #{status}")
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
