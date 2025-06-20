# ASCII Art Backend Examples

This directory contains examples demonstrating how to use Delux's ASCII art backend for LED visualization in the terminal.

## What is the ASCII Art Backend?

The ASCII art backend is a special backend for Delux that renders LED states as colored text in your terminal instead of controlling physical LEDs. This is incredibly useful for:

- **Development**: Test LED patterns without hardware
- **Debugging**: Visualize complex LED sequences
- **Demos**: Show LED behavior in presentations
- **Learning**: Understand how Delux effects work
- **Testing**: Automated testing of LED logic

## Running the Examples

### Basic ASCII Art Example

```bash
cd examples
elixir ascii_art_example.exs
```

This comprehensive example demonstrates:

- Basic color rendering
- Blinking patterns at different frequencies
- Color cycling effects
- Morse code transmission
- Multiple indicators running simultaneously
- Brightness adjustment effects

### Interactive Example

```bash
cd examples
elixir -S mix run interactive_ascii_example.exs
```

An interactive version where you can:

- Choose which effects to run
- Adjust parameters in real-time
- Test your own LED patterns

## How It Works

### Backend Configuration

To use the ASCII art backend, configure Delux like this:

```elixir
# Start the ASCII art server (handles terminal rendering)
{:ok, _pid} = Delux.Backend.AsciiArtServer.start_link([])

# Configure Delux with the ASCII art backend
{:ok, delux_pid} = Delux.start_link(
  backend: %{module: Delux.Backend.AsciiArt},
  indicators: %{
    status: %{red: "status_red", green: "status_green", blue: "status_blue"},
    network: %{green: "net_green", red: "net_red"}
  }
)
```

### Key Differences from Hardware Backend

1. **No Physical LEDs**: LED names are just identifiers for display
2. **Terminal Rendering**: Colors appear as ANSI-colored text
3. **Real-time Updates**: Patterns update in your terminal window
4. **No Hardware Dependencies**: Works on any system with a terminal

### Visual Output

The ASCII art backend displays indicators like this:

```text
status_red | net_green | user_blue
```

Where each indicator name is colored according to its current RGB state. The colors blend and change in real-time as patterns execute.

## Backend Architecture

The ASCII art backend consists of three main components:

### 1. `Delux.Backend.AsciiArt`

- Main backend module implementing the `Delux.Backend` behavior
- Manages indicator instances
- Compiles and runs LED programs

### 2. `Delux.Backend.AsciiArtIndicator`

- Individual indicator process
- Executes LED patterns with precise timing
- Updates color states at ~10Hz for smooth animation

### 3. `Delux.Backend.AsciiArtServer`

- Terminal rendering server
- Manages ANSI terminal output
- Handles multiple indicators display

## Creating Custom Examples

You can easily create your own ASCII art examples:

```elixir
# Start the system
{:ok, _} = Delux.Backend.AsciiArtServer.start_link([])
{:ok, delux} = Delux.start_link(
  backend: %{module: Delux.Backend.AsciiArt},
  indicators: %{my_led: %{red: "r", green: "g", blue: "b"}}
)

# Test any effect
Delux.render(delux, %{my_led: Delux.Effects.blink(:red, 2)}, :status)

# Watch it blink in the terminal!
Process.sleep(5000)

# Clean up
GenServer.stop(delux)
GenServer.stop(Delux.Backend.AsciiArtServer)
```

## Integrating with Tests

The ASCII art backend is perfect for automated testing:

```elixir
defmodule MyLedTest do
  use ExUnit.Case

  test "LED pattern works correctly" do
    {:ok, _} = Delux.Backend.AsciiArtServer.start_link([])
    {:ok, delux} = Delux.start_link(
      backend: %{module: Delux.Backend.AsciiArt},
      indicators: %{test: %{red: "r"}}
    )

    # Test your LED logic
    Delux.render(delux, %{test: Delux.Effects.on(:red)}, :status)

    # Verify behavior (ASCII backend provides introspection)
    assert Delux.info_as_ansidata(delux, :test) |> IO.ANSI.format(false) =~ "red"

    # Cleanup
    GenServer.stop(delux)
    GenServer.stop(Delux.Backend.AsciiArtServer)
  end
end
```

## Tips and Tricks

### Terminal Compatibility

- Works best with terminals supporting ANSI colors
- Use `IO.ANSI.enabled?()` to check color support
- Colors may appear differently in different terminals

### Performance

- Updates at ~10Hz for smooth animation
- Minimal CPU usage compared to hardware backends
- No file I/O or kernel interaction needed

### Debugging

- Add `IO.inspect/2` calls to see internal state
- Use `:observer.start()` to watch processes
- Check `Delux.info/2` for human-readable status

### Multiple Instances

- You can run multiple Delux instances with ASCII art
- Each needs its own name to avoid conflicts
- Useful for testing complex multi-device scenarios

## Limitations

- No actual LED control (obviously!)
- Terminal window must remain visible to see output
- Color representation limited by terminal capabilities
- Timing precision depends on terminal update rates

## Next Steps

After experimenting with the ASCII art backend:

1. **Hardware Testing**: Switch to `Delux.Backend.PatternTrigger` for real LEDs
2. **Custom Effects**: Create your own LED patterns using `Delux.Program`
3. **Integration**: Add LED control to your applications
4. **Advanced Features**: Explore priority slots and indicator grouping

The ASCII art backend makes it easy to develop and test LED behavior before deploying to hardware!
