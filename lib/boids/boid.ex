defmodule Boids.Boid do
  use GenServer
  require Logger

  @frame_duration Application.get_env(:boids, :frame_duration)

  #API
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(arg) do
    Logger.info("Init called with arg #{inspect arg}")
    ##TODO "Render" by saving position in the buffer
    move_after(@frame_duration)
    {:ok, arg}
  end

  def handle_info(:try_move, state) do
    Logger.info("Move called with state: #{inspect state}")
    move_after(@frame_duration)
    {:noreply, state}
  end

  defp move_after(time_delay_ms) do
    Process.send_after(self(), :try_move, time_delay_ms)
  end
end
