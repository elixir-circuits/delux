#!/usr/bin/env elixir

# Debug test for ASCII art server

Mix.install([
  {:delux, path: ".."}
])

IO.puts("=== Debug Test ===")

# Start the server manually first
{:ok, server_pid} =
  Delux.Backend.AsciiArtServer.start_link(mode: :rich_blocks, update_interval: 1000)

IO.puts("ASCII art server started: #{inspect(server_pid)}")

# Manually test the server
IO.puts("Testing server update...")
# Red
:ok = Delux.Backend.AsciiArtServer.update("test_led", {1.0, 0.0, 0.0})
IO.puts("Update sent to server")

Process.sleep(2000)

# Green
:ok = Delux.Backend.AsciiArtServer.update("test_led", {0.0, 1.0, 0.0})
IO.puts("Second update sent")

Process.sleep(2000)

# Blue
:ok = Delux.Backend.AsciiArtServer.update("test_led", {0.0, 0.0, 1.0})
IO.puts("Third update sent")

Process.sleep(2000)

GenServer.stop(server_pid)
IO.puts("Test complete")
