defmodule Boids do
  use Application

  def start(_type, _args) do
    children = [Boids.SimpleSupervisor, Boids.BoidsSupervisor]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
