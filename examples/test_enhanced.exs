#!/usr/bin/env elixir

# Simple test of the enhanced ASCII art server

Mix.install([
  {:delux, path: ".."}
])

# Configure Delux with rich blocks mode
{:ok, _delux_pid} =
  Delux.start_link(
    backend: %{
      module: Delux.Backend.AsciiArt,
      mode: :rich_blocks,
      update_interval: 1000
    },
    indicators: %{
      test: %{red: "r", green: "g", blue: "b"}
    }
  )

IO.puts("Testing enhanced ASCII art backend...")
IO.puts("Watch for timestamped LED updates below:\n")

# Test sequence
IO.puts("Setting LED to red...")
Delux.render(%{test: Delux.Effects.on(:red)})
Process.sleep(3000)

IO.puts("Setting LED to green...")
Delux.render(%{test: Delux.Effects.on(:green)})
Process.sleep(3000)

IO.puts("Blinking blue...")
Delux.render(%{test: Delux.Effects.blink(:blue, 2)})
Process.sleep(5000)

IO.puts("Turning off...")
Delux.clear()
Process.sleep(2000)

IO.puts("Test complete!")
