defmodule Boids.Buffer do
  use Agent
  require Logger

  # API
  def start_link(_arg) do
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  def add_boid_state(pname, boid_state) do
    Agent.update(__MODULE__, &Map.put(&1, pname, boid_state))
  end

  def get_boid_state(pname) do
    Agent.get(__MODULE__, &Map.get(&1, pname, ""))
  end

  def get_all_boid_states do
    Agent.get(__MODULE__, &(Map.to_list(&1) |> Map.new()))
  end
end
