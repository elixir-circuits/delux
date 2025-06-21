defmodule Delux.Backend.AsciiArtServer do
  @moduledoc """
  Renderer for ASCII Art indicators

  This module renders a status bar so you can see the current state of the
  LEDs in your terminal.
  """
  use GenServer

  # Unicode blocks for LED intensity representation
  # Empty circle
  @led_off "○"
  # Half-filled circle
  @led_dim "◐"
  # Different half-filled
  @led_medium "◑"
  # Filled circle
  @led_bright "●"
  # Hexagon (like LED package)
  @led_full "⬢"

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
  defp render_led_status_bar({name, {r, g, b}}) do
    color = rgb_to_ansi_color({r, g, b})
    symbol = intensity_to_symbol(calculate_intensity({r, g, b}))
    [color, symbol, IO.ANSI.reset(), " ", to_string(name)]
  end

  defp calculate_intensity({r, g, b}) do
    # Calculate perceived brightness using standard luminance formula
    0.299 * r + 0.587 * g + 0.114 * b
  end

  defp intensity_to_symbol(intensity) when intensity >= 0.8, do: @led_full
  defp intensity_to_symbol(intensity) when intensity >= 0.6, do: @led_bright
  defp intensity_to_symbol(intensity) when intensity >= 0.4, do: @led_medium
  defp intensity_to_symbol(intensity) when intensity >= 0.2, do: @led_dim
  defp intensity_to_symbol(_), do: @led_off

  defp rgb_to_ansi_color({r, g, b}) do
    # Convert RGB values (0.0-1.0) to integers (0-5) for IO.ANSI.color/3
    r_int = round(r * 5)
    g_int = round(g * 5)
    b_int = round(b * 5)
    IO.ANSI.color(r_int, g_int, b_int)
  end
end
