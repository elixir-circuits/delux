#!/usr/bin/env elixir

# Enhanced ASCII Art Backend Example
#
# This example demonstrates the improved ASCII art backend with multiple
# visualization modes that are IEx-friendly and provide better LED representation.

Mix.install([
  {:delux, path: ".."}
])

defmodule EnhancedAsciiExample do
  @moduledoc """
  Demonstrates the enhanced ASCII art backend with multiple visualization modes.

  Modes available:
  - :iex_friendly - Periodic timestamped updates, IEx prompt safe
  - :rich_blocks - Unicode symbols with intensity levels
  - :status_bar - Fixed status bar (traditional mode)
  """

  alias Delux.Effects

  def run do
    IO.puts("=== Enhanced ASCII Art Backend Demo ===\n")

    show_visualization_modes()

    mode = get_visualization_mode()

    # Configure Delux with the chosen visualization mode
    {:ok, delux_pid} =
      Delux.start_link(
        name: :enhanced_demo,
        backend: %{
          module: Delux.Backend.AsciiArt,
          mode: mode,
          # Faster updates for demo
          update_interval: 300
        },
        indicators: %{
          led1: %{red: "r1", green: "g1", blue: "b1"},
          led2: %{red: "r2", green: "g2", blue: "b2"},
          led3: %{red: "r3", green: "g3", blue: "b3"}
        }
      )

    IO.puts("\nUsing visualization mode: #{mode}")
    IO.puts("Watch the LED indicators below...\n")

    case mode do
      :status_bar ->
        IO.puts("LED status will appear at the top of your terminal.")
        IO.puts("Note: This mode may interfere with IEx prompt.\n")

      :iex_friendly ->
        IO.puts("LED status updates will appear as timestamped log entries.")
        IO.puts("This mode is safe to use with IEx.\n")

      :rich_blocks ->
        IO.puts("LED status will show with Unicode symbols indicating intensity.")
        IO.puts("This mode is also IEx-friendly.\n")
    end

    run_demo_sequence(delux_pid)

    IO.puts("\nDemo complete! The #{mode} mode provides:")
    print_mode_benefits(mode)

    GenServer.stop(delux_pid)
  end

  defp show_visualization_modes do
    IO.puts("Available visualization modes:")
    IO.puts("1. IEx Friendly - Timestamped updates, safe with IEx (recommended)")
    IO.puts("2. Rich Blocks - Unicode symbols with intensity levels")
    IO.puts("3. Status Bar - Fixed top-line status (may interfere with IEx)")
    IO.puts("")
  end

  defp get_visualization_mode do
    IO.write("Choose mode (1-3, default 1): ")

    case IO.read(:line) |> String.trim() do
      "2" -> :rich_blocks
      "3" -> :status_bar
      _ -> :iex_friendly
    end
  end

  defp run_demo_sequence(delux_pid) do
    # Demo 1: Basic colors with intensity progression
    IO.puts("Demo 1: Color intensity progression")

    for intensity <- [0.2, 0.5, 0.8, 1.0] do
      # Red with varying intensity
      color = {intensity, 0, 0}
      Delux.render(delux_pid, %{led1: Effects.on(color)}, :status)
      Process.sleep(2000)
    end

    # Demo 2: Multiple LEDs with different patterns
    IO.puts("Demo 2: Multiple LED patterns")

    Delux.render(
      delux_pid,
      %{
        led1: Effects.blink(:red, 2),
        led2: Effects.on(:green),
        led3: Effects.cycle([:blue, :cyan], 3)
      },
      :status
    )

    Process.sleep(5000)

    # Demo 3: Color mixing
    IO.puts("Demo 3: RGB color mixing")

    colors = [
      # Pure red
      {1.0, 0.0, 0.0},
      # Orange
      {1.0, 0.5, 0.0},
      # Yellow
      {1.0, 1.0, 0.0},
      # Green
      {0.0, 1.0, 0.0},
      # Cyan
      {0.0, 1.0, 1.0},
      # Blue
      {0.0, 0.0, 1.0},
      # Purple
      {0.5, 0.0, 1.0},
      # Magenta
      {1.0, 0.0, 1.0}
    ]

    for color <- colors do
      Delux.render(delux_pid, %{led2: Effects.on(color)}, :status)
      Process.sleep(1500)
    end

    # Demo 4: Intensity levels
    IO.puts("Demo 4: Brightness levels")

    Delux.render(delux_pid, %{led1: Effects.on(:white)}, :status)

    for brightness <- [100, 75, 50, 25, 10, 0] do
      Delux.adjust_brightness(delux_pid, brightness)
      Process.sleep(1500)
    end

    # Demo 5: Turn everything off
    IO.puts("Demo 5: Turning off")
    Delux.clear(delux_pid, :status)
    Process.sleep(2000)
  end

  defp print_mode_benefits(:iex_friendly) do
    IO.puts("✓ Safe to use with IEx REPL")
    IO.puts("✓ Timestamped updates for debugging")
    IO.puts("✓ Non-intrusive output")
    IO.puts("✓ Easy to scroll back through history")
  end

  defp print_mode_benefits(:rich_blocks) do
    IO.puts("✓ Visual intensity indicators with Unicode symbols")
    IO.puts("✓ Color-coded LED states")
    IO.puts("✓ IEx-friendly timestamped output")
    IO.puts("✓ More intuitive LED representation")
  end

  defp print_mode_benefits(:status_bar) do
    IO.puts("✓ Real-time updating status bar")
    IO.puts("✓ Compact display")
    IO.puts("✓ Similar to hardware debugging tools")
    IO.puts("⚠ May interfere with IEx prompt")
  end
end

# Run the enhanced demo
EnhancedAsciiExample.run()
