defmodule Boids.SimpleSupervisor do
  use Supervisor
  require Logger

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, :ok, arg)
  end

  @impl true
  def init(_arg) do
    children = [
      Boids.Animator,
      Boids.Buffer
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
