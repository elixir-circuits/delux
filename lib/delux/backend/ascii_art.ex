defmodule Delux.Backend.AsciiArt do
  @moduledoc """
  Show LED animations as ASCII art
  """
  @behaviour Delux.Backend

  alias Delux.Backend
  alias Delux.Backend.AsciiArtIndicator
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
    # Extract ASCII art specific options
    mode = options[:mode] || :iex_friendly
    update_interval = options[:update_interval] || 500

    # Start the indicator with ASCII art specific configuration
    indicator_opts =
      options
      |> Map.put(:mode, mode)
      |> Map.put(:update_interval, update_interval)
      |> Map.to_list()

    {:ok, pid} = AsciiArtIndicator.start_link(indicator_opts)
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
    AsciiArtIndicator.run(state.pid, compiled)
    :infinity
  end

  @doc """
  Free resources
  """
  @impl Backend
  def close(%__MODULE__{} = state) do
    GenServer.stop(state.pid)
    :ok
  end
end
