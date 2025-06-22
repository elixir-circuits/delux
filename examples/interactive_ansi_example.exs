#!/usr/bin/env elixir

# Interactive ANSI Backend Example
#
# This provides an interactive way to test the ANSI backend with
# different effects and settings.

Mix.install([
  {:delux, path: ".."}
])

defmodule InteractiveANSIExample do
  @moduledoc """
  Interactive demo for the ANSI backend.

  This allows you to experiment with different LED effects and see them
  rendered in real-time in your terminal.
  """

  alias Delux.Backend.ANSI
  alias Delux.Effects
  alias Delux.Morse

  def run() do
    IO.puts("=== Interactive Delux ANSI Backend ===\n")

    # Start the ANSI server
    {:ok, _pid} = ANSI.Server.start_link([])

    # Clear screen and setup display
    IO.write(IO.ANSI.clear())
    IO.puts("LED Visualization (watch the line below):")
    IO.puts("=" |> String.duplicate(60))
    IO.puts("")
    IO.puts("Commands will be shown here...")
    IO.puts("")

    # Configure Delux with multiple indicators
    {:ok, delux_pid} =
      Delux.start_link(
        name: :interactive_demo,
        backend: %{module: Delux.Backend.ANSI},
        indicators: %{
          led1: %{red: "led1_r", green: "led1_g", blue: "led1_b"},
          led2: %{red: "led2_r", green: "led2_g", blue: "led2_b"},
          led3: %{red: "led3_r", green: "led3_g", blue: "led3_b"}
        }
      )

    # Start interactive loop
    interactive_loop(delux_pid)

    # Cleanup
    GenServer.stop(delux_pid)
    GenServer.stop(ANSI.Server)
  end

  defp interactive_loop(delux_pid) do
    show_menu()

    case get_choice() do
      "1" ->
        test_colors(delux_pid)

      "2" ->
        test_blinking(delux_pid)

      "3" ->
        test_cycling(delux_pid)

      "4" ->
        test_morse(delux_pid)

      "5" ->
        test_multiple(delux_pid)

      "6" ->
        test_brightness(delux_pid)

      "7" ->
        custom_effect(delux_pid)

      "c" ->
        clear_all(delux_pid)

      "q" ->
        :quit

      _ ->
        IO.puts("Invalid choice. Try again.")
        Process.sleep(1000)
    end
    |> case do
      :quit -> IO.puts("\nGoodbye!")
      _ -> interactive_loop(delux_pid)
    end
  end

  defp show_menu() do
    IO.puts("\n--- Choose an effect ---")
    IO.puts("1. Solid Colors")
    IO.puts("2. Blinking")
    IO.puts("3. Color Cycling")
    IO.puts("4. Morse Code")
    IO.puts("5. Multiple Indicators")
    IO.puts("6. Brightness Adjustment")
    IO.puts("7. Custom Effect")
    IO.puts("c. Clear All")
    IO.puts("q. Quit")
    IO.write("Choice: ")
  end

  defp get_choice() do
    IO.read(:line) |> String.trim() |> String.downcase()
  end

  defp test_colors(delux_pid) do
    IO.puts("\nSolid Colors Demo")
    IO.write("Choose color (red/green/blue/yellow/cyan/magenta/white): ")

    color_name = IO.read(:line) |> String.trim() |> String.downcase()

    color =
      case color_name do
        "red" ->
          :red

        "green" ->
          :green

        "blue" ->
          :blue

        "yellow" ->
          :yellow

        "cyan" ->
          :cyan

        "magenta" ->
          :magenta

        "white" ->
          :white

        _ ->
          IO.puts("Unknown color, using white")
          :white
      end

    IO.write("Choose LED (1, 2, 3, or 'all'): ")
    led_choice = IO.read(:line) |> String.trim() |> String.downcase()

    case led_choice do
      "1" ->
        Delux.render(delux_pid, %{led1: Effects.on(color)}, :status)

      "2" ->
        Delux.render(delux_pid, %{led2: Effects.on(color)}, :status)

      "3" ->
        Delux.render(delux_pid, %{led3: Effects.on(color)}, :status)

      "all" ->
        Delux.render(
          delux_pid,
          %{
            led1: Effects.on(color),
            led2: Effects.on(color),
            led3: Effects.on(color)
          },
          :status
        )

      _ ->
        IO.puts("Invalid LED choice")
    end

    IO.puts("Effect applied! Press Enter to continue...")
    IO.read(:line)
  end

  defp test_blinking(delux_pid) do
    IO.puts("\nBlinking Demo")
    IO.write("Choose frequency (1-10 Hz): ")

    freq =
      case IO.read(:line) |> String.trim() |> Integer.parse() do
        {f, _} when f > 0 and f <= 10 ->
          f

        _ ->
          IO.puts("Invalid frequency, using 2 Hz")
          2
      end

    IO.write("Choose color (red/green/blue/yellow/cyan/magenta/white): ")
    color_name = IO.read(:line) |> String.trim() |> String.downcase()

    color =
      case color_name do
        "red" -> :red
        "green" -> :green
        "blue" -> :blue
        "yellow" -> :yellow
        "cyan" -> :cyan
        "magenta" -> :magenta
        "white" -> :white
        _ -> :green
      end

    Delux.render(delux_pid, %{led1: Effects.blink(color, freq)}, :status)

    IO.puts("LED1 blinking at #{freq} Hz. Press Enter to continue...")
    IO.read(:line)
  end

  defp test_cycling(delux_pid) do
    IO.puts("\nColor Cycling Demo")
    IO.write("Choose speed (1-5): ")

    speed =
      case IO.read(:line) |> String.trim() |> Integer.parse() do
        {s, _} when s > 0 and s <= 5 -> s
        _ -> 2
      end

    colors = [:red, :green, :blue, :yellow, :cyan, :magenta]
    Delux.render(delux_pid, %{led2: Effects.cycle(colors, speed)}, :status)

    IO.puts("LED2 cycling colors at #{speed} Hz. Press Enter to continue...")
    IO.read(:line)
  end

  defp test_morse(delux_pid) do
    IO.puts("\nMorse Code Demo")
    IO.write("Enter message to send: ")

    message = IO.read(:line) |> String.trim() |> String.upcase()

    if String.length(message) > 0 do
      IO.write("Words per minute (5-20): ")

      wpm =
        case IO.read(:line) |> String.trim() |> Integer.parse() do
          {w, _} when w >= 5 and w <= 20 -> w
          _ -> 10
        end

      morse_program = Morse.encode(:blue, message, words_per_minute: wpm)
      Delux.render(delux_pid, %{led3: morse_program}, :status)

      IO.puts("LED3 sending '#{message}' at #{wpm} WPM. Press Enter to continue...")
      IO.read(:line)
    else
      IO.puts("No message entered.")
    end
  end

  defp test_multiple(delux_pid) do
    IO.puts("\nMultiple Indicators Demo")
    IO.puts("Setting up different patterns on all LEDs...")

    Delux.render(
      delux_pid,
      %{
        led1: Effects.blink(:red, 1),
        led2: Effects.cycle([:green, :blue], 2),
        led3: Effects.on(:yellow)
      },
      :status
    )

    IO.puts("All LEDs active with different patterns. Press Enter to continue...")
    IO.read(:line)
  end

  defp test_brightness(delux_pid) do
    IO.puts("\nBrightness Adjustment Demo")

    # Set a bright pattern first
    Delux.render(delux_pid, %{led1: Effects.on(:white)}, :status)

    IO.puts("LED1 at full brightness")
    Process.sleep(2000)

    for brightness <- [75, 50, 25, 10] do
      Delux.adjust_brightness(delux_pid, brightness)
      IO.puts("Brightness: #{brightness}%")
      Process.sleep(2000)
    end

    # Reset to full
    Delux.adjust_brightness(delux_pid, 100)
    IO.puts("Back to full brightness. Press Enter to continue...")
    IO.read(:line)
  end

  defp custom_effect(delux_pid) do
    IO.puts("\nCustom Effect Builder")
    IO.puts("Let's create a custom pattern...")

    IO.write("Number of blinks (1-10): ")

    count =
      case IO.read(:line) |> String.trim() |> Integer.parse() do
        {c, _} when c > 0 and c <= 10 -> c
        _ -> 3
      end

    IO.write("Color: ")
    color_name = IO.read(:line) |> String.trim() |> String.downcase()

    color =
      case color_name do
        "red" -> :red
        "green" -> :green
        "blue" -> :blue
        "yellow" -> :yellow
        "cyan" -> :cyan
        "magenta" -> :magenta
        "white" -> :white
        _ -> :white
      end

    # Create a custom blinking pattern
    custom_program = Effects.number_blink(color, count, :medium)
    Delux.render(delux_pid, %{led1: custom_program}, :status)

    IO.puts("Custom pattern: #{count} blinks in #{color}. Press Enter to continue...")
    IO.read(:line)
  end

  defp clear_all(delux_pid) do
    IO.puts("\nClearing all LEDs...")
    Delux.clear(delux_pid, :status)
    IO.puts("All LEDs cleared. Press Enter to continue...")
    IO.read(:line)
  end
end

# Start the interactive demo
InteractiveANSIExample.run()
