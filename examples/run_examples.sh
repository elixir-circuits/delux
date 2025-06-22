#!/bin/bash

# ANSI Backend Examples Runner
# This script helps you run the different ANSI backend examples

echo "=== Delux ANSI Backend Examples ==="
echo
echo "Available examples:"
echo "1. ansi_test.exs           - Simple functionality test"
echo "2. ansi_example.exs        - Original comprehensive demo"
echo "3. interactive_ansi_example.exs - Interactive demo"
echo "4. enhanced_ansi_example.exs    - Enhanced visualization modes"
echo "5. iex_friendly_example.exs     - IEx-optimized example"
echo
echo "Choose an example to run:"
echo

read -r -p "Enter number (1-5): " choice

case $choice in
    1)
        echo "Running functionality test..."
        elixir ansi_test.exs
        ;;
    2)
        echo "Running original comprehensive example..."
        echo "This will show various LED effects - watch the terminal!"
        elixir ansi_example.exs
        ;;
    3)
        echo "Starting interactive demo..."
        echo "You'll be able to control LED effects in real-time!"
        elixir interactive_ansi_example.exs
        ;;
    4)
        echo "Running enhanced visualization demo..."
        echo "Choose from multiple visualization modes!"
        elixir enhanced_ansi_example.exs
        ;;
    5)
        echo "Running IEx-friendly example..."
        echo "Perfect for use within an IEx session!"
        elixir iex_friendly_example.exs
        ;;
    *)
        echo "Invalid choice. Please run again and choose 1-5."
        exit 1
        ;;
esac
