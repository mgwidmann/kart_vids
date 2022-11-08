defmodule KartVids.Races.ListenerSupervisor do
  @moduledoc false
  use Parent.GenServer
  require Logger
  alias KartVids.Content
  alias KartVids.Races.Listener

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(arg), do: Parent.GenServer.start_link(__MODULE__, arg)

  @impl GenServer
  @spec init(any) :: {:ok, nil}
  def init(_) do
    send(self(), :start_locations)
    {:ok, nil}
  end

  @delay_minutes 1
  @delay @delay_minutes * 60 * 1000 # 5 minutes

  @impl Parent.GenServer
  def handle_stopped_children(stopped_children, state) do
    Logger.info("Websocket connection unstable, will retry connecting in #{@delay_minutes} minutes #{inspect stopped_children}")
    Process.send_after(self(), {:restart, stopped_children}, @delay)
    {:noreply, state}
  end

  def handle_info({:restart, stopped_children}, state) do
    Logger.info("Attempting to restoring websocket connection #{inspect stopped_children}")
    Parent.return_children(stopped_children)
    {:noreply, state}
  end

  def handle_info({:start_location, location}, state) do
    start_location(location)

    {:noreply, state}
  end

  def handle_info(:start_locations, state) do
    Logger.info("Starting location websocket connections...")

    locations = Content.list_locations()
    for location <- locations do
      start_location(location)
    end

    Logger.info("All done starting location listeners!")

    {:noreply, state}
  end

  def handle_info(message, state) do
    super(message, state)
  end

  defp start_location(location) do
    try do
      {:ok, _} = Parent.start_child(Listener.child_spec(location))
    rescue
      _ ->
        Logger.info("Trouble with starting location #{location.name} (#{location.id}) (will try again in #{@delay_minutes} minute(s))")
        Process.send_after(self(), {:start_location, location}, @delay)
    catch
      _ ->
        Logger.info("Trouble with starting location #{location.name} (#{location.id}) (will try again in #{@delay_minutes} minute(s))")
        Process.send_after(self(), {:start_location, location}, @delay)
    end
  end
end
