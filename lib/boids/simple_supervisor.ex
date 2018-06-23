defmodule Boids.SimpleSupervisor do
  use Supervisor
  require Logger

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      Boids.Buffer,
      Boids.Animator
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
