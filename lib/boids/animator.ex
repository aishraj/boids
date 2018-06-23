defmodule Boids.Animator do
  use GenServer
  require Logger
  require Poison
  alias Boids.{Buffer, Physics.Vector}

  @max_grid_size Application.get_env(:boids, :max_grid_size)

  # API
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  # callbacks
  def init(arg) do
    Process.send(self(), :initialize_simulation, arg)
    {:ok, []}
  end

  def handle_info(:initialize_simulation, _state) do
    create_birds(Application.get_env(:boids, :number_boids))
    render_json(Application.get_env(:boids, :frame_duration))
    {:noreply, []}
  end

  def handle_info(:render_json, _state) do
    render_json(Application.get_env(:boids, :frame_duration))
    {:noreply, []}
  end

  # private
  defp create_birds(n) do
    1..n
    |> Enum.shuffle()
    |> Enum.each(fn index ->
      new_bird(
        %Boids.Boid{
          position: Vector.new(:rand.uniform(@max_grid_size), :rand.uniform(@max_grid_size)),
          velocity: Vector.random(),
          accleration: Vector.new()
        },
        index
      )
    end)
  end

  defp new_bird(boid, index) do
    spec = %{
      id: :"boid_#{index}",
      name: :"boid_#{index}",
      start: {Boids.Boid, :start_link, [{boid, index}]}
    }

    DynamicSupervisor.start_child(Boids.DynamicSupervisor, spec)
  end

  defp render_json(time_delay_ms) do
    Buffer.get_all_boid_states() |> Poison.encode!() |> IO.puts()
    Process.send_after(self(), :render_json, time_delay_ms)
  end
end
