#!/usr/bin/env elixir

# IEx-Friendly ASCII Art Example
#
# This example is specifically designed to work well within an IEx session,
# providing LED visualization without interfering with the REPL prompt.

Mix.install([
  {:delux, path: ".."}
])

# Start Delux with IEx-friendly ASCII art backend
{:ok, _delux_pid} =
  Delux.start_link(
    backend: %{
      module: Delux.Backend.AsciiArt,
      # Unicode symbols for better visualization
      mode: :rich_blocks,
      # Update every second
      update_interval: 1000
    },
    indicators: %{
      status: %{red: "status_r", green: "status_g", blue: "status_b"},
      network: %{green: "net_g", red: "net_r"},
      activity: %{blue: "activity_b"}
    }
  )

IO.puts("""
=== IEx-Friendly LED Control ===

Your Delux system is now running with ASCII art visualization!

Try these commands in IEx:

# Basic LED control
Delux.render(Delux.Effects.on(:red))
Delux.render(Delux.Effects.blink(:green, 2))
Delux.render(Delux.Effects.cycle([:red, :green, :blue], 1))

# Multiple indicators
Delux.render(%{
  status: Delux.Effects.on(:green),
  network: Delux.Effects.blink(:blue, 1),
  activity: Delux.Effects.off()
})

# Morse code
Delux.render(%{status: Delux.Morse.encode(:red, "HELLO")})

# Check status
Delux.info()

# Clear all
Delux.clear()

Watch for timestamped LED status updates that won't interfere with your IEx prompt!

LED Status Legend:
⬢ Full intensity    ● Bright    ◑ Medium    ◐ Dim    ○ Off

""")

# Show a quick demo
IO.puts("Quick demo - watch the LED updates:")

Delux.render(Delux.Effects.on(:red))
Process.sleep(2000)

Delux.render(%{
  status: Delux.Effects.blink(:green, 2),
  network: Delux.Effects.on(:blue),
  activity: Delux.Effects.cycle([:yellow, :cyan], 3)
})

Process.sleep(5000)

Delux.clear()

IO.puts("\nDemo complete! Now try the commands above in your IEx session.")
IO.puts("The LED visualization will continue to work without interfering with IEx.")
