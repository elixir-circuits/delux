defmodule Delux.Backend.ANSI do
  @moduledoc """
  Show LED animations as ANSI art
  """
  @behaviour Delux.Backend

  alias Delux.Backend
  alias Delux.Backend.ANSI
  alias Delux.Program

  defstruct [:pid]

  @typedoc false
  @type state() :: %{pid: pid()}

  @doc """
  Open and prep file handles for writing patterns

  Options:
  * `:name` - the indicator's name
  * `:red` - the name of the red LED if it exists
  * `:green` - the name of the green LED if it exists
  * `:blue` - the name of the blue LED if it exists
  * `:mode` - visualization mode (:iex_friendly, :status_bar, :rich_blocks)
  * `:update_interval` - milliseconds between updates (default: 500)
  """
  @impl Backend
  def open(options) do
    # Ensure supervisor is started
    ensure_supervisor_started(options)

    # Extract ANSI art specific options
    mode = options[:mode] || :iex_friendly
    update_interval = options[:update_interval] || 500

    # Start the indicator with ANSI art specific configuration
    indicator_opts =
      options
      |> Map.put(:mode, mode)
      |> Map.put(:update_interval, update_interval)

    {:ok, pid} = ANSI.Supervisor.start_indicator(indicator_opts)
    %__MODULE__{pid: pid}
  end

  @doc """
  Compile an indicator program so that it can be run efficiently later
  """
  @impl Backend
  def compile(%__MODULE__{} = _state, %Program{} = program, _percent) do
    program
  end

  @doc """
  Run a compiled program at the specified time offset

  This returns the amount of time left.

  NOTE: Specifying a time offset isn't supported yet.
  """
  @impl Backend
  def run(%__MODULE__{} = state, compiled, _time_offset) do
    ANSI.Indicator.run(state.pid, compiled)
    :infinity
  end

  @doc """
  Free resources
  """
  @impl Backend
  def close(%__MODULE__{} = state) do
    ANSI.Supervisor.stop_indicator(state.pid)
    :ok
  end

  # Private helper to ensure the supervisor is started
  defp ensure_supervisor_started(options) do
    case Process.whereis(ANSI.Supervisor.supervisor_name()) do
      nil ->
        update_interval = options[:update_interval] || 500
        {:ok, _pid} = ANSI.Supervisor.start_link(update_interval: update_interval)
        :ok

      _pid ->
        :ok
    end
  end
end
