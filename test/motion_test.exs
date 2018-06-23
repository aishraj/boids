defmodule Boids.MotionTest do
  use ExUnit.Case
  alias Boids.{Boid, Physics.Vector, Motion}

  test "separation rule returns a valid separation vector if there are boids in vicinity" do
    thisboid = %Boid{
      position: Vector.new(3,3),
      velocity: Vector.new(0,1),
      accleration: Vector.new()
    }

    neighbor_boids = [makeboid({5,2}, {1,0}), makeboid({5,4}, {0,1})]
    result_vector = Motion.separate(thisboid, neighbor_boids)
    assert result_vector.x != 0 #TODO figure out better
    assert result_vector.y != 0

  end


  test "cohesion rule returns a valid vector when there are boids in vicinity" do
    thisboid = %Boid{
      position: Vector.new(3,3),
      velocity: Vector.new(0,1),
      accleration: Vector.new()
    }

    neighbor_boids = [makeboid({5,2}, {1,0}), makeboid({5,4}, {0,1})]
    result_vector = Motion.align(thisboid, neighbor_boids)
    assert result_vector.x != 0 #TODO figure out better
    assert result_vector.y != 0
  end

  test "alignment returns a valid vector when there are boids in vicinity" do
     thisboid = %Boid{
      position: Vector.new(3,3),
      velocity: Vector.new(0,1),
      accleration: Vector.new()
    }

    neighbor_boids = [makeboid({5,2}, {1,0}), makeboid({5,4}, {0,1})]
    result_vector = Motion.coh(thisboid, neighbor_boids)
    assert result_vector.x != 0 #TODO figure out better
    assert result_vector.y != 0
  end

  test "seek moves the boid in the correct direction" do
    seek_vec = Vector.new(1,1)
    thisboid = %Boid{
      position: Vector.new(3,3),
      velocity: Vector.new(0,1),
      accleration: Vector.new()
    }
    moved = Motion.seek(seek_vec, thisboid)
    assert moved.x != 0
    assert moved.y != 0

 end

  defp makeboid({px,py},{vx,vy}) do
    %Boid{
      position: Vector.new(px,py),
      velocity: Vector.new(vx,vy),
      accleration: Vector.new(),
    }
  end

 end
