defmodule KartVids.Memory do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    handle_info(:memory, nil)
    {:ok, nil}
  end

  @memory_print_timeout System.get_env("MEMORY_PRINT_TIMEOUT_MS", Integer.to_string(60_000)) |> Integer.parse() |> elem(0)

  def handle_info(:memory, _state) do
    Process.send_after(self(), :memory, @memory_print_timeout)
    report_memory()
    {:noreply, nil}
  end

  def report_memory() do
    Logger.info("Top Memory: #{inspect(top_memory())}")
  end

  def top_memory(n \\ 10) do
    :recon.proc_count(:memory, 10_000_000) |> Enum.sort_by(fn {_pid, mem, _details} -> -mem end) |> Enum.take(n)
  end
end
