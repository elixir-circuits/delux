#!/usr/bin/env elixir

# ASCII Art Backend Example
#
# This example demonstrates how to use Delux's ASCII art backend to visualize
# LED patterns in the terminal instead of controlling physical LEDs. This is
# useful for:
# - Development and testing without hardware
# - Debugging LED patterns
# - Demos and presentations
# - Understanding how different effects look

# Mix.install is used to demonstrate this as a standalone script
Mix.install([
  {:delux, path: ".."}
])

defmodule AsciiArtExample do
  @moduledoc """
  Demonstrates the ASCII art backend for Delux LED control.

  The ASCII art backend renders LED states as colored text in the terminal,
  allowing you to see how your LED programs will behave without physical hardware.
  """

  alias Delux.Backend.AsciiArtServer
  alias Delux.Effects
  alias Delux.Morse

  def run() do
    IO.puts("=== Delux ASCII Art Backend Example ===\n")

    # Start the ASCII art server that handles terminal rendering
    {:ok, _pid} = AsciiArtServer.start_link([])

    # Clear the screen and show a header
    IO.write(IO.ANSI.clear())
    IO.puts("LED states will be displayed below (Ctrl+C to exit):")
    IO.puts("=" |> String.duplicate(50))
    IO.puts("")

    # Configure Delux with the ASCII art backend
    # This creates multiple indicators to show different patterns
    {:ok, delux_pid} =
      Delux.start_link(
        name: :ascii_example,
        backend: %{module: Delux.Backend.AsciiArt},
        indicators: %{
          status: %{red: "status_r", green: "status_g", blue: "status_b"},
          network: %{green: "net_g", red: "net_r"},
          user: %{blue: "user_b", white: "user_w"},
          rgb_demo: %{red: "rgb_r", green: "rgb_g", blue: "rgb_b"}
        }
      )

    # Run through various examples
    demo_basic_colors(delux_pid)
    demo_blinking_patterns(delux_pid)
    demo_color_cycling(delux_pid)
    demo_morse_code(delux_pid)
    demo_multiple_indicators(delux_pid)
    demo_brightness_levels(delux_pid)

    # Clean shutdown
    IO.puts("\n\nExample complete! Press any key to exit...")
    IO.read(:line)

    GenServer.stop(delux_pid)
    GenServer.stop(AsciiArtServer)
  end

  defp demo_basic_colors(delux_pid) do
    IO.puts("1. Basic Colors Demo")
    IO.puts("   Testing solid colors on the status indicator...")

    colors = [:red, :green, :blue, :yellow, :cyan, :magenta, :white]

    for color <- colors do
      Delux.render(delux_pid, %{status: Effects.on(color)}, :status)
      IO.puts("   Current: #{color}")
      Process.sleep(1000)
    end

    # Turn off
    Delux.render(delux_pid, %{status: Effects.off()}, :status)
    Process.sleep(500)
  end

  defp demo_blinking_patterns(delux_pid) do
    IO.puts("\n2. Blinking Patterns Demo")
    IO.puts("   Different blink frequencies on network indicator...")

    frequencies = [1, 2, 5, 10]

    for freq <- frequencies do
      Delux.render(delux_pid, %{network: Effects.blink(:green, freq)}, :status)
      IO.puts("   Blinking green at #{freq} Hz")
      Process.sleep(3000)
    end

    Delux.clear(delux_pid, :status)
    Process.sleep(500)
  end

  defp demo_color_cycling(delux_pid) do
    IO.puts("\n3. Color Cycling Demo")
    IO.puts("   Cycling through colors on RGB demo indicator...")

    # Cycle through RGB colors
    Delux.render(delux_pid, %{rgb_demo: Effects.cycle([:red, :green, :blue], 2)}, :status)
    IO.puts("   Cycling: red -> green -> blue at 2 Hz")
    Process.sleep(5000)

    # Cycle through more colors
    Delux.render(
      delux_pid,
      %{rgb_demo: Effects.cycle([:red, :yellow, :green, :cyan, :blue, :magenta], 3)},
      :status
    )

    IO.puts("   Cycling through rainbow colors at 3 Hz")
    Process.sleep(5000)

    Delux.clear(delux_pid, :status)
    Process.sleep(500)
  end

  defp demo_morse_code(delux_pid) do
    IO.puts("\n4. Morse Code Demo")
    IO.puts("   Sending 'HELLO WORLD' in Morse code...")

    morse_program = Morse.encode(:blue, "HELLO WORLD", words_per_minute: 15)
    Delux.render(delux_pid, %{user: morse_program}, :status)

    IO.puts("   Morse: HELLO WORLD (15 WPM)")
    IO.puts("   H = .... | E = . | L = .-.. | L = .-.. | O = ---")
    IO.puts("   W = .-- | O = --- | R = .-. | L = .-.. | D = -..")

    # Let it play for a while
    Process.sleep(10000)

    Delux.clear(delux_pid, :status)
    Process.sleep(500)
  end

  defp demo_multiple_indicators(delux_pid) do
    IO.puts("\n5. Multiple Indicators Demo")
    IO.puts("   Running different patterns on all indicators simultaneously...")

    # Start different patterns on different indicators
    Delux.render(
      delux_pid,
      %{
        status: Effects.blink(:red, 1),
        network: Effects.blink(:green, 2),
        user: Effects.cycle([:blue, :white], 3),
        rgb_demo: Effects.on(:yellow)
      },
      :status
    )

    IO.puts("   status: red blink 1Hz | network: green blink 2Hz")
    IO.puts("   user: blue/white cycle 3Hz | rgb_demo: solid yellow")
    Process.sleep(8000)

    # Clear all
    Delux.clear(delux_pid, :status)
    Process.sleep(1000)
  end

  defp demo_brightness_levels(delux_pid) do
    IO.puts("\n6. Brightness Adjustment Demo")
    IO.puts("   Testing brightness levels (note: ASCII art shows intensity via patterns)...")

    # Set a bright pattern
    Delux.render(delux_pid, %{rgb_demo: Effects.on(:white)}, :status)
    IO.puts("   Brightness: 100%")
    Process.sleep(2000)

    # Adjust brightness down
    brightness_levels = [75, 50, 25, 10]

    for brightness <- brightness_levels do
      Delux.adjust_brightness(delux_pid, brightness)
      IO.puts("   Brightness: #{brightness}%")
      Process.sleep(2000)
    end

    # Back to full brightness
    Delux.adjust_brightness(delux_pid, 100)
    IO.puts("   Brightness: 100%")
    Process.sleep(1000)

    Delux.clear(delux_pid, :status)
  end
end

# Run the example
AsciiArtExample.run()
