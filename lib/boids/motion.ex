defmodule Boids.Motion do
  require Logger
  alias Boids.Physics.Vector

  @max_speed 10

  def applyforce(boid, force) do
    %Boids.Boid{
      position: boid.position,
      velocity: boid.velocity,
      accleration: Vector.add(boid.accleration, force)
    }
  end

  def move_boid(boid, others) do
    sep = separate(boid, others)
    aln = align(boid, others)
    coh = coh(boid, others)

    Logger.debug(
      "Sep Align and Cohesion vectors are #{inspect(sep)} #{inspect(aln)} and #{inspect(coh)}"
    )

    boid
      |> applyforce(sep)
      |> applyforce(aln)
      |> applyforce(coh)
      |> move
  end

  def separate(%Boids.Boid{} = boid, others) do
    # Logger.info("Size of boids in separate is #{length(others)}")
    min_space = 10

    {steer_vec, count} =
      others
      |> Enum.filter(fn neighbour ->
        distance = Vector.distance(boid.position, neighbour.position)
        distance > 0 && distance < min_space
      end)
      |> Enum.map(fn neighbour ->
        Vector.diff(boid.position, neighbour.position)
        |> Vector.normalize()
        |> Vector.vec_div(Vector.distance(boid.position, neighbour.position))
      end)
      |> Enum.reduce({Vector.new(0, 0), 0}, fn diff, {s, c} -> {Vector.add(s, diff), c + 1} end)

    Logger.debug("Steer and count are #{inspect(steer_vec)} and #{inspect(count)}")

    steer =
      case count do
        0 -> steer_vec
        _ -> Vector.vec_div(steer_vec, count)
      end

    case Vector.magnitude(steer) do
      0 ->
        steer

      _ ->
        steer
        |> Vector.normalize()
        |> Vector.mult(@max_speed)
        |> Vector.diff(boid.velocity)
    end
  end

  def align(%Boids.Boid{} = boid, others) do
    # Logger.info("Size of boids in align is #{length(others)}")
    neighbour_dist = 10

    {vec, count} =
      others
      |> Enum.reduce({Vector.new(), 0}, fn neighbour, {s, c} ->
        d = Vector.distance(boid.position, neighbour.position)

        if d > 0 && d < neighbour_dist do
          {Vector.add(s, neighbour.velocity), c + 1}
        else
          {s, c}
        end
      end)

    Logger.debug("Align prevec and count are #{inspect({vec, count})}")

    case count do
      0 ->
        Vector.new()

      _ ->
        vec
        |> Vector.vec_div(count)
        |> Vector.normalize()
        |> Vector.mult(@max_speed)
        |> Vector.diff(boid.velocity)
    end
  end

  def coh(%Boids.Boid{} = boid, others) do
    # Logger.info("Size of boids in coh is #{length(others)}")
    neighbour_dist = 50

    {vec, count} =
      others
      |> Enum.reduce({Vector.new(), 0}, fn neighbour, {s, c} ->
        d = Vector.distance(boid.position, neighbour.position)

        if d > 0 && d < neighbour_dist do
          {Vector.add(s, neighbour.velocity), c + 1}
        else
          {s, c}
        end
      end)

    case count do
      0 ->
        Vector.new()

      _ ->
        vec
        |> Vector.vec_div(count)
        |> seek(boid)
    end
  end

  def seek(target, %Boids.Boid{} = boid) do
    target
    |> Vector.diff(boid.position)
    |> Vector.normalize()
    |> Vector.mult(@max_speed)
    |> Vector.diff(boid.velocity)
  end

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
