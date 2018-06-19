defmodule Boids.Boid do
  use GenServer
  alias Boids.{Buffer, Physics.Vector}
  require Logger

  @frame_duration Application.get_env(:boids, :frame_duration)
  @max_grid_size Application.get_env(:boids, :max_grid_size)
  @max_speed 4

  defstruct(
    position: Vector.new(:rand.uniform(@max_grid_size), :rand.uniform(@max_grid_size)),
    velocity: Vector.random(),
    accleration: Vector.new()
  )


  #API
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(arg) do
    Logger.info("Init called with arg #{inspect arg}")
    render_position(arg)
    move_after(@frame_duration)
    {:ok, arg}
  end

  def handle_info(:try_move, state) do
    Logger.debug("Move called with state: #{inspect state}")
    next_position = calculate_next_position(state)
    render_position(next_position)
    move_after(@frame_duration)
    {:noreply, next_position}
  end

  #Private
  defp render_position({%Boids.Boid{}= boid, index}) do
    position_x = boid.position.x
    position_y = boid.position.y
   Buffer.add_position(index, [position_x, position_y])
  end

  defp applyforce(boid, force) do 
  %Boids.Boid{
    position: boid.position,
    velocity: boid.velocity,
    accleration: Vector.add(boid.accleration, force)
   }
  end

  defp calculate_next_position({%Boids.Boid{} = boid, index}) do
    others = [] #TODO: Change this
    sep = separate(boid, others)
    aln = align(boid, others)
    coh = coh(boid, others)
    Logger.debug("Sep Align and Cohesion vectors are #{inspect sep} #{inspect aln} and #{inspect coh}")
    rboid = boid
          |> applyforce(sep)
          |> applyforce(aln)
          |> applyforce(coh)
          |> move
    Logger.info("Old #{inspect boid} New #{inspect rboid}")
    {rboid, index}
  end

  defp separate(%Boids.Boid{} = boid, others) do
    min_space = 25
    {steer_vec, count} = others
      |> Enum.filter(fn neighbour -> 
        distance = Vector.distance(boid.position, neighbour.position)
        distance > 0 &&  distance < min_space
      end)
      |> Enum.map(fn neighbour -> 
        Vector.diff(boid.position, neighbour.position) 
              |> Vector.normalize
              |> Vector.vec_div(Vector.distance(boid.position, neighbour.position))
      end)
      |> Enum.reduce({Vector.new(0,0), 0}, fn(diff, {s, c}) -> {Vector.add(s, diff), c + 1} end)
    Logger.debug("Steer and count are #{inspect steer_vec} and #{inspect count}")
    steer = case count do
      0 -> steer_vec
      _ -> Vector.vec_div(steer_vec, count)
    end
    Logger.debug("Steer is now #{inspect steer}")
    case Vector.magnitude(steer) do
      0 -> steer
      _ -> steer
          |> Vector.normalize()
          |> Vector.mult(@max_speed)
          |> Vector.diff(boid.velocity)
    end
  end

  defp align(%Boids.Boid{} = boid, others) do
    neighbour_dist = 50
    {vec, count} = others 
      |> Enum.reduce({Vector.new(), 0}, fn(neighbour, {s, c}) -> 
        d = Vector.distance(boid.position, neighbour.position) 
          if (d > 0 && d < neighbour_dist) do
              {Vector.add(s, neighbour.velocity), c + 1}
          else
            {s, c}
          end
        end)
    case count do
      0 -> Vector.new()
      _ -> vec
          |> Vector.vec_div(count)
          |> Vector.normalize()
          |> Vector.mult(@max_speed)
          |> Vector.diff(boid.velocity)
    end
  end

  defp coh(%Boids.Boid{} = boid, others) do
    neighbour_dist = 5
    {vec, count} = others
    |> Enum.reduce({Vector.new(), 0}, fn(neighbour, {s, c}) -> 
      d = Vector.distance(boid.position, neighbour.position)
      if (d > 0 && d < neighbour_dist) do
          {Vector.add(s, neighbour.velocity), c + 1}
      else
        {s, c}
      end
    end)
    case count do
      0 -> Vector.new()
      _ -> vec
          |> Vector.vec_div(count)
          |> seek(boid)
    end
  end

  defp seek(target, %Boids.Boid{} = boid) do
    target
    |> Vector.diff(boid.position)
    |> Vector.normalize
    |> Vector.mult(@max_speed)
    |> Vector.diff(boid.velocity)
  end

  defp move_after(time_delay_ms) do
    Process.send_after(self(), :try_move, time_delay_ms)
  end

  defp move(%Boids.Boid{} = boid) do
    Logger.info("The boid is now #{inspect boid}")
    future_velocity = Vector.add(boid.velocity, boid.accleration)
    Logger.info("Future velocity is #{inspect future_velocity}")
    %Boids.Boid{
      velocity: Vector.add(boid.velocity, boid.accleration),
      position: Vector.add(boid.position, boid.velocity),
      accleration: Vector.new() #reset to 0
    }
  end
end
