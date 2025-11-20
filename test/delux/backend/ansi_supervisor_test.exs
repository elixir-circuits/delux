defmodule Delux.Backend.ANSI.SupervisorTest do
  use ExUnit.Case, async: false

  alias Delux.Backend.ANSI
  alias Delux.Backend.ANSI.Supervisor, as: ANSISupervisor

  describe "ANSI backend supervision" do
    test "supervisor starts and manages ANSI.Server and DynamicSupervisor" do
      # Clean up any existing processes
      if Process.whereis(ANSISupervisor.supervisor_name()) do
        Supervisor.stop(ANSISupervisor.supervisor_name())
      end

      # Start the supervisor
      {:ok, supervisor_pid} = ANSISupervisor.start_link(update_interval: 100)
      assert Process.alive?(supervisor_pid)

      # Verify ANSI.Server is running
      server_pid = Process.whereis(ANSI.Server)
      assert server_pid != nil
      assert Process.alive?(server_pid)

      # Verify DynamicSupervisor is running
      dynamic_supervisor_pid = Process.whereis(ANSISupervisor.dynamic_supervisor_name())
      assert dynamic_supervisor_pid != nil
      assert Process.alive?(dynamic_supervisor_pid)

      # Clean up
      Supervisor.stop(supervisor_pid)
    end

    test "open/1 starts indicator via DynamicSupervisor" do
      # Clean up any existing processes
      if Process.whereis(ANSISupervisor.supervisor_name()) do
        Supervisor.stop(ANSISupervisor.supervisor_name())
      end

      # Test opening an indicator
      options = [name: "test_led", red: "red", green: "green", blue: "blue"]
      state = ANSI.open(options)

      assert is_pid(state.pid)
      assert Process.alive?(state.pid)

      # Verify the supervisor tree is running
      supervisor_pid = Process.whereis(ANSISupervisor.supervisor_name())
      assert supervisor_pid != nil

      # Test closing the indicator
      assert :ok = ANSI.close(state)
      refute Process.alive?(state.pid)

      # Clean up supervisor
      Supervisor.stop(supervisor_pid)
    end

    test "multiple indicators can be managed simultaneously" do
      # Clean up any existing processes
      if Process.whereis(ANSISupervisor.supervisor_name()) do
        Supervisor.stop(ANSISupervisor.supervisor_name())
      end

      # Start multiple indicators
      state1 = ANSI.open(name: "led1", red: "red1")
      state2 = ANSI.open(name: "led2", green: "green2")

      assert is_pid(state1.pid)
      assert is_pid(state2.pid)
      assert state1.pid != state2.pid
      assert Process.alive?(state1.pid)
      assert Process.alive?(state2.pid)

      # Close one indicator
      assert :ok = ANSI.close(state1)
      refute Process.alive?(state1.pid)
      assert Process.alive?(state2.pid)

      # Close the other indicator
      assert :ok = ANSI.close(state2)
      refute Process.alive?(state2.pid)

      # Clean up supervisor
      supervisor_pid = Process.whereis(ANSISupervisor.supervisor_name())

      if supervisor_pid do
        Supervisor.stop(supervisor_pid)
      end
    end
  end
end
