defmodule Boids.BoidsSupervisor do
  use Supervisor
  require Logger
  alias Boids.{Physics.Vector}

  @max_grid_size Application.get_env(:boids, :max_grid_size)
  @max_velocity Application.get_env(:boids, :max_velocity)

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = build_children_spec(Application.get_env(:boids, :number_boids))
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp build_children_spec(n) do
    1..n
    |> Enum.shuffle()
    |> Enum.map(fn index ->
      new_boid_spec(
        %Boids.Boid{
          position: Vector.new(:rand.uniform(@max_grid_size), :rand.uniform(@max_grid_size)),
          velocity: Vector.new(:rand.uniform(@max_velocity), :rand.uniform(@max_velocity)),
          accleration: Vector.new()
        },
        index
      )
    end)
  end

  defp new_boid_spec(boid, index) do
    %{
      id: :"boid_#{index}",
      name: :"boid_#{index}",
      start: {Boids.Boid, :start_link, [{boid, index}]}
    }
  end
end
