defmodule Boids.Animator do
  use GenServer
  require Logger
  require Poison
  alias Boids.{Buffer}

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
    render_json(Application.get_env(:boids, :frame_duration))
    {:noreply, []}
  end

  def handle_info(:render_json, _state) do
    render_json(Application.get_env(:boids, :frame_duration))
    {:noreply, []}
  end

  # private
   defp render_json(time_delay_ms) do
    Buffer.get_all_boid_states() |> Poison.encode!() |> IO.puts()
    Process.send_after(self(), :render_json, time_delay_ms)
  end
end
