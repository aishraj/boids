defmodule Boids.Animator do
  use GenServer
  require Logger

  #API
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(arg) do
    Process.send(self(), :initialize_simulation, arg)
    {:ok, []}
  end

  def handle_info(:initialize_simulation, _state) do
    Logger.info("Starting birds now......")
    create_birds(Application.get_env(:boids, :number_boids))
    {:noreply, []}
  end

  def create_birds(n) do
    (0..n-1)
    |> Enum.shuffle
    |> Enum.with_index
    |> Enum.each(fn {pos,id} -> new_bird(id,pos) end)
  end

  defp new_bird(bird_id, pos_x) do
    spec = %{id: Boid, start: {Boids.Boid, :start_link, [{bird_id, pos_x}]}}
    DynamicSupervisor.start_child(Boids.DynamicSupervisor, spec)
  end
end
