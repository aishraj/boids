defmodule Boids.Boid do
  use GenServer
  alias Boids.{Buffer, Physics.Vector, Motion}
  require Logger

  @frame_duration Application.get_env(:boids, :frame_duration)
  @max_grid_size Application.get_env(:boids, :max_grid_size)

  defstruct(
    position: Vector.new(:rand.uniform(@max_grid_size), :rand.uniform(@max_grid_size)),
    velocity: Vector.random(),
    accleration: Vector.new()
  )

  # API
  def start_link({state, index}) do
    GenServer.start_link(__MODULE__, {state, index}, name: generate_name(index))
  end

  @impl true
  def init({state, index}) do
    Logger.debug("Init called with arg #{inspect({state, index})}")
    render_position({state, generate_name(index)})
    move_after(@frame_duration)
    {:ok, {state, index}}
  end

  @impl true
  def handle_info(:try_move, state) do
    Logger.debug("Move called with state: #{inspect(state)}")
    {new_state, index} = calculate_next_position(state)
    render_position({new_state, generate_name(index)})
    move_after(@frame_duration)
    {:noreply, {new_state, index}}
  end

  # Private
  defp render_position({%Boids.Boid{} = boid, boid_name}) do
    Buffer.add_boid_state(boid_name, boid)
  end

  defp calculate_next_position({%Boids.Boid{} = boid, index}) do
    others =
      Buffer.get_all_boid_states()
      |> Enum.filter(fn {k, _} -> k != generate_name(index) end)
      |> Enum.map(fn {_, v} -> v end)

    Logger.debug("Size of others after calculating is #{length(others)}")
    sep = Motion.separate(boid, others)
    aln = Motion.align(boid, others)
    coh = Motion.coh(boid, others)

    Logger.info(
      "Sep Align and Cohesion vectors are #{inspect(sep)} #{inspect(aln)} and #{inspect(coh)}"
    )

    rboid =
      boid
      |> Motion.applyforce(sep)
      |> Motion.applyforce(aln)
      |> Motion.applyforce(coh)
      |> move

    {rboid, index}
  end

  defp move_after(time_delay_ms) do
    Process.send_after(self(), :try_move, time_delay_ms)
  end

  defp generate_name(index), do: :"boid_#{index}"

  defp move(%Boids.Boid{} = boid) do
    future_velocity = Vector.add(boid.velocity, boid.accleration)
    Logger.debug("Future velocity is #{inspect(future_velocity)}")

    %Boids.Boid{
      velocity: Vector.add(boid.velocity, boid.accleration),
      position: Vector.add(boid.position, boid.velocity),
      # reset to 0
      accleration: Vector.new()
    }
  end
end
