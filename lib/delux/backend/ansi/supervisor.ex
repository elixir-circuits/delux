defmodule Delux.Backend.ANSI.Supervisor do
  @moduledoc """
  Supervisor for the ANSI backend components.

  This supervisor manages:
  - ANSI.Server for rendering the display
  - DynamicSupervisor for managing ANSI.Indicator processes
  """
  use Supervisor

  alias Delux.Backend.ANSI

  @supervisor_name __MODULE__
  @dynamic_supervisor_name ANSI.IndicatorSupervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: @supervisor_name)
  end

  def start_indicator(opts) do
    DynamicSupervisor.start_child(@dynamic_supervisor_name, {ANSI.Indicator, opts})
  end

  def stop_indicator(pid) when is_pid(pid) do
    DynamicSupervisor.terminate_child(@dynamic_supervisor_name, pid)
  end

  def supervisor_name, do: @supervisor_name
  def dynamic_supervisor_name, do: @dynamic_supervisor_name

  @impl Supervisor
  def init(opts) do
    update_interval = opts[:update_interval] || 500

    children = [
      {ANSI.Server, [update_interval: update_interval]},
      {DynamicSupervisor, name: @dynamic_supervisor_name, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
