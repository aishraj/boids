defmodule Boids.Buffer do
  use Agent
  require Logger

  #API
  def start_link(_arg) do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def add_position(pid, position) do
    Agent.update(__MODULE__, &Map.put(&1, pid, position))
  end

  def get_position(pid) do
    Agent.get(__MODULE__, &Map.get(&1, pid, ""))
  end

  def get_all_positions do
    Agent.get(__MODULE__, &Map.to_list(&1) |> Map.new)
  end

end
