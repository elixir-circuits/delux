#!/bin/bash

# ASCII Art Backend Examples Runner
# This script helps you run the different ASCII art backend examples

echo "=== Delux ASCII Art Backend Examples ==="
echo
echo "Available examples:"
echo "1. ascii_art_test.exs      - Simple functionality test"
echo "2. ascii_art_example.exs   - Comprehensive demo of all features"
echo "3. interactive_ascii_example.exs - Interactive demo"
echo
echo "Choose an example to run:"
echo

read -r -p "Enter number (1-3): " choice

case $choice in
    1)
        echo "Running functionality test..."
        elixir ascii_art_test.exs
        ;;
    2)
        echo "Running comprehensive example..."
        echo "This will show various LED effects - watch the terminal!"
        elixir ascii_art_example.exs
        ;;
    3)
        echo "Starting interactive demo..."
        echo "You'll be able to control LED effects in real-time!"
        elixir interactive_ascii_example.exs
        ;;
    *)
        echo "Invalid choice. Please run again and choose 1, 2, or 3."
        exit 1
        ;;
esac
