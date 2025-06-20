defmodule Delux.Backend.AsciiArtServer do
  @moduledoc """
  Renderer for all ASCII Art indicators

  Supports multiple visualization modes:
  - `:iex_friendly` - Periodic status updates that don't interfere with IEx
  - `:status_bar` - Fixed status bar at top of terminal
  - `:rich_blocks` - Unicode block characters for better LED representation
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

  defstruct [:gl, :indicators, :mode, :last_update, :update_interval]

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

  @spec set_mode(atom()) :: :ok
  def set_mode(mode) when mode in [:iex_friendly, :status_bar, :rich_blocks] do
    GenServer.call(__MODULE__, {:set_mode, mode})
  end

  @impl GenServer
  def init(opts) do
    mode = opts[:mode] || :iex_friendly
    update_interval = opts[:update_interval] || 500

    # Start a timer for periodic updates (except for status_bar mode)
    timer_ref =
      case mode do
        :status_bar ->
          nil

        _ ->
          {:ok, ref} = :timer.send_interval(update_interval, :update_display)
          ref
      end

    {:ok,
     %__MODULE__{
       indicators: %{},
       gl: Process.group_leader(),
       mode: mode,
       last_update: 0,
       # Reuse this field for timer ref
       update_interval: timer_ref
     }}
  end

  @impl GenServer
  def handle_call({:update, name, rgb}, _from, state) do
    new_indicators = Map.put(state.indicators, name, rgb)
    new_state = %{state | indicators: new_indicators}

    # Render immediately in status_bar mode, otherwise wait for timer
    case state.mode do
      :status_bar -> render(new_state)
      _ -> :ok
    end

    {:reply, :ok, new_state}
  end

  @impl GenServer
  def handle_call({:set_mode, mode}, _from, state) do
    # Cancel existing timer if any
    if state.update_interval, do: :timer.cancel(state.update_interval)

    # Start new timer if needed
    timer_ref =
      case mode do
        :status_bar ->
          nil

        _ ->
          {:ok, ref} = :timer.send_interval(500, :update_display)
          ref
      end

    new_state = %{state | mode: mode, update_interval: timer_ref}
    {:reply, :ok, new_state}
  end

  @impl GenServer
  def handle_info(:update_display, state) do
    render(state)
    {:noreply, state}
  end

  defp render(%{mode: :iex_friendly} = state) do
    if not Enum.empty?(state.indicators) do
      timestamp = Time.utc_now() |> Time.to_string()

      status =
        state.indicators
        |> Enum.sort()
        |> Enum.map(&render_led_iex_friendly/1)
        |> Enum.join("  ")

      IO.puts(state.gl, "[#{timestamp}] LEDs: #{status}")
    end
  end

  defp render(%{mode: :rich_blocks} = state) do
    if not Enum.empty?(state.indicators) do
      timestamp = Time.utc_now() |> Time.to_string()

      status =
        state.indicators
        |> Enum.sort()
        |> Enum.map(&render_led_rich_blocks/1)
        |> Enum.join("  ")

      IO.puts(state.gl, "[#{timestamp}] #{status}")
    end
  end

  defp render(%{mode: :status_bar} = state) do
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
      "LEDs: ",
      str,
      IO.ANSI.reset(),
      @ansi_pop_state
    ])
  end

  # IEx-friendly rendering - just colored text
  defp render_led_iex_friendly({name, {r, g, b}}) do
    color = rgb_to_ansi_color({r, g, b})
    intensity = calculate_intensity({r, g, b})

    if intensity > 0 do
      [color, to_string(name), IO.ANSI.reset()] |> IO.ANSI.format()
    else
      to_string(name)
    end
  end

  # Rich blocks rendering - Unicode symbols with colors
  defp render_led_rich_blocks({name, {r, g, b}}) do
    color = rgb_to_ansi_color({r, g, b})
    symbol = intensity_to_symbol(calculate_intensity({r, g, b}))

    [color, symbol, " ", to_string(name), IO.ANSI.reset()] |> IO.ANSI.format()
  end

  # Status bar rendering - compact colored indicators
  defp render_led_status_bar({name, {r, g, b}}) do
    color = rgb_to_ansi_color({r, g, b})
    [color, name]
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
    # Convert RGB values to closest ANSI color
    cond do
      r > 0.8 and g < 0.3 and b < 0.3 -> :red
      r < 0.3 and g > 0.8 and b < 0.3 -> :green
      r < 0.3 and g < 0.3 and b > 0.8 -> :blue
      r > 0.8 and g > 0.8 and b < 0.3 -> :yellow
      r > 0.8 and g < 0.3 and b > 0.8 -> :magenta
      r < 0.3 and g > 0.8 and b > 0.8 -> :cyan
      r > 0.6 and g > 0.6 and b > 0.6 -> :white
      r > 0.3 or g > 0.3 or b > 0.3 -> :light_black
      true -> :black
    end
  end
end
