defmodule VectorTest do
  use ExUnit.Case
  alias Boids.Physics.Vector

  test "vector addition follows arithmetic for components" do
    v1 = Vector.new(1,1)
    v2 = Vector.new(-34,0)
    v3 = Vector.add(v1,v2)
    assert v3.x == -33
    assert v3.y == 1
  end

  test "vector division by scalar works" do
    v1 = Vector.new(46,23)
    n = 23
    v2 = Vector.vec_div(v1,n)
    assert v2.x == 2
    assert v2.y == 1
  end

  test "vector multiplication works" do
    v1 = Vector.new(1,2)
    n = -33
    v2 = Vector.mult(v1,n)
    assert v2.x == -33
    assert v2.y == -66
  end

  test "vector diff works" do
    v1 = Vector.new(10,1)
    v2 = Vector.new(0,3)
    v3 = Vector.diff(v1,v2)
    assert v3.x == 10
    assert v3.y == -2
  end

  test "vector sub works" do
    v1 = Vector.new(10,1)
    v3 = Vector.sub(v1)
    assert v3.x == 9
    assert v3.y == 0
  end

  test "vector inc works" do
    v1 = Vector.new(9,0)
    v3 = Vector.inc(v1)
    assert v3.x == 10
    assert v3.y == 1
  end

  test "vector magnitude works" do
    v1 = Vector.new(3,4)
    m = Vector.magnitude(v1)
    assert m == 5.0
  end

  test "vector distance works" do
    v1 = Vector.new(3,5)
    v2 = Vector.new(0,9)
    v3 = Vector.distance(v1,v2)
    assert v3 == 5.0
  end

  test "vector normalize works for vector of magnitude 1" do
    v1 = Vector.new(1,0)
    n = Vector.normalize(v1)
    assert v1 == n
  end

  test "vector normalize works for vector of other magnitude" do
    v1 = Vector.new(3,4)
    n = Vector.normalize(v1)
    assert n.x == 3/5
    assert n.y == 4/5
  end
end
