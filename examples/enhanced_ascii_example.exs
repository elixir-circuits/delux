#!/usr/bin/env elixir

# Enhanced ASCII Art Backend Example
#
Mix.install([
  {:delux, path: ".."}
])

defmodule EnhancedAsciiExample do
  @moduledoc """
  Demonstrates the enhanced ASCII art backend.
  """

  alias Delux.Effects

  def run do
    IO.puts("=== Enhanced ASCII Art Backend Demo ===\n")

    # Configure Delux with the chosen visualization mode
    {:ok, delux_pid} =
      Delux.start_link(
        name: :enhanced_demo,
        backend: %{
          module: Delux.Backend.AsciiArt,
          # Faster updates for demo
          update_interval: 300
        },
        indicators: %{
          led1: %{red: "r1", green: "g1", blue: "b1"},
          led2: %{red: "r2", green: "g2", blue: "b2"},
          led3: %{red: "r3", green: "g3", blue: "b3"}
        }
      )

    IO.puts("Watch the LED indicators at the top of your terminal...\n")

    run_demo_sequence(delux_pid)

    GenServer.stop(delux_pid)
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
end

# Run the enhanced demo
EnhancedAsciiExample.run()
