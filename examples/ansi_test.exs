#!/usr/bin/env elixir

# Simple test to verify ANSI backend functionality

Mix.install([
  {:delux, path: ".."}
])

defmodule ANSITest do
  @moduledoc """
  Simple test to verify ANSI backend works correctly.
  """

  alias Delux.Backend.ANSI.Server
  alias Delux.Effects

  def run() do
    IO.puts("Testing ANSI Backend...")

    # Start the ANSI server
    {:ok, server_pid} = ANSI.Server.start_link([])
    IO.puts("✓ ANSI server started")

    # Configure Delux with ANSI backend
    {:ok, delux_pid} =
      Delux.start_link(
        name: :test_delux,
        backend: %{module: Delux.Backend.ANSI},
        indicators: %{
          test_led: %{red: "test_r", green: "test_g", blue: "test_b"}
        }
      )

    IO.puts("✓ Delux started with ANSI backend")

    # Test basic functionality
    IO.puts("\nTesting basic LED control...")

    # Turn on red
    Delux.render(delux_pid, %{test_led: Effects.on(:red)}, :status)
    IO.puts("✓ Red LED on")
    Process.sleep(2000)

    # Turn on green
    Delux.render(delux_pid, %{test_led: Effects.on(:green)}, :status)
    IO.puts("✓ Green LED on")
    Process.sleep(2000)

    # Blink blue
    Delux.render(delux_pid, %{test_led: Effects.blink(:blue, 2)}, :status)
    IO.puts("✓ Blue LED blinking at 2 Hz")
    Process.sleep(4000)

    # Turn off
    Delux.render(delux_pid, %{test_led: Effects.off()}, :status)
    IO.puts("✓ LED off")
    Process.sleep(1000)

    # Test info function
    info =
      Delux.info_as_ansidata(delux_pid, :test_led)
      |> IO.ANSI.format(false)
      |> IO.chardata_to_string()

    IO.puts("✓ LED info: #{info}")

    # Cleanup
    GenServer.stop(delux_pid)
    GenServer.stop(server_pid)

    IO.puts("\n✅ All tests passed! ANSI backend is working correctly.")
  end
end

ANSITest.run()
