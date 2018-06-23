defmodule Boids.Physics.Vector do
  defstruct x: nil, y: nil

  @max_grid_size Application.get_env(:boids, :max_grid_size)

  def new(), do: Boids.Physics.Vector.new(0, 0)
  def new(a, b), do: %Boids.Physics.Vector{x: a, y: b}

  def random(),
    do: Boids.Physics.Vector.new(:rand.uniform(@max_grid_size), :rand.uniform(@max_grid_size))

  def add(%Boids.Physics.Vector{} = v1, %Boids.Physics.Vector{} = v2),
    do: %Boids.Physics.Vector{x: v1.x + v2.x, y: v1.y + v2.y}

  def vec_div(%Boids.Physics.Vector{} = vector, n),
    do: %Boids.Physics.Vector{x: vector.x / n, y: vector.y / n}

  def mult(%Boids.Physics.Vector{} = vector, n),
    do: %Boids.Physics.Vector{x: vector.x * n, y: vector.y * n}

  def sub(%Boids.Physics.Vector{} = vector),
    do: %Boids.Physics.Vector{x: vector.x - 1, y: vector.y - 1}

  def diff(%Boids.Physics.Vector{} = v1, %Boids.Physics.Vector{} = v2),
    do: %Boids.Physics.Vector{x: v1.x - v2.x, y: v1.y - v2.y}

  def inc(%Boids.Physics.Vector{} = vector),
    do: %Boids.Physics.Vector{x: vector.x + 1, y: vector.y + 1}

  def magnitude(%Boids.Physics.Vector{} = vector),
    do: :math.sqrt(vector.x * vector.x + vector.y * vector.y)

  def mag_square(%Boids.Physics.Vector{} = vector), do: vector.x * vector.x + vector.y * vector.y

  def distance(%Boids.Physics.Vector{} = v1, %Boids.Physics.Vector{} = v2) do
    dx = v1.x - v2.x
    dy = v1.y - v2.y
    :math.sqrt(dx * dx + dy * dy)
  end

  def normalize(%Boids.Physics.Vector{} = vector), do: normalize(vector, magnitude(vector))
  def normalize(%Boids.Physics.Vector{} = vector, 0), do: vector
  def normalize(%Boids.Physics.Vector{} = vector, 0.0), do: vector
  def normalize(%Boids.Physics.Vector{} = vector, 1.0), do: vector
  def normalize(%Boids.Physics.Vector{} = vector, mag), do: vec_div(vector, mag)
end
