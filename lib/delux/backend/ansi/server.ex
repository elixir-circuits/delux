defmodule Delux.Backend.ANSI.Server do
  @moduledoc """
  Renderer for ANSI indicators

  This module renders a status bar so you can see the current state of the
  LEDs in your terminal.
  """
  use GenServer

  # Unicode blocks for LED intensity representation
  @led_off "○"
  @led_on "●"

  # Status bar ANSI codes (only used in status_bar mode)
  @ansi_push_state "\e[s"
  @ansi_pop_state "\e[u"
  @ansi_move_upper_left "\e[1;1H"
  @ansi_clear_line "\e[K"

  defstruct [:gl, :indicators, :last_update, :update_interval]

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec stop(GenServer.server()) :: :ok
  def stop(server) do
    GenServer.stop(server)
  end

  @spec update(atom() | String.t(), tuple()) :: :ok
  def update(indicator_name, rgb) do
    GenServer.call(__MODULE__, {:update, indicator_name, rgb})
  end

  @impl GenServer
  def init(opts) do
    update_interval = opts[:update_interval] || 500

    # Start a timer for periodic updates
    {:ok, timer_ref} = :timer.send_interval(update_interval, :update_display)

    {:ok,
     %__MODULE__{
       indicators: %{},
       gl: Process.group_leader(),
       last_update: 0,
       update_interval: timer_ref
     }}
  end

  @impl GenServer
  def handle_call({:update, name, rgb}, _from, state) do
    new_indicators = Map.put(state.indicators, name, rgb)
    new_state = %{state | indicators: new_indicators}
    {:reply, :ok, new_state}
  end

  @impl GenServer
  def handle_info(:update_display, state) do
    render(state)
    {:noreply, state}
  end

  defp render(state) do
    timestamp = Time.utc_now() |> Time.to_string() |> String.slice(0, 8)

    str =
      state.indicators
      |> Enum.sort()
      |> Enum.map(&render_led_status_bar/1)
      |> Enum.intersperse(" | ")
      |> IO.ANSI.format()

    IO.write(state.gl, [
      @ansi_push_state,
      @ansi_move_upper_left,
      @ansi_clear_line,
      "[#{timestamp}] LEDs: ",
      str,
      IO.ANSI.reset(),
      @ansi_pop_state
    ])
  end

  # Status bar rendering - Unicode LED symbols with uncolored names
  defp render_led_status_bar({name, color}) do
    [rgb_to_ansi_color(color), symbol(color), IO.ANSI.default_color(), " ", to_string(name)]
  end

  defp symbol({0, 0, 0}), do: @led_off
  defp symbol(_), do: @led_on

  defp rgb_to_ansi_color({r, g, b}) do
    # Convert RGB values (0.0-1.0) to integers (0-5) for IO.ANSI.color/3
    IO.ANSI.color(round(r * 5), round(g * 5), round(b * 5))
  end
end
