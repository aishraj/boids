defmodule Boids.Boid do
  use GenServer
  alias Boids.Buffer
  require Logger

  @frame_duration Application.get_env(:boids, :frame_duration)

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
    Logger.info("Move called with state: #{inspect state}")
    next_position = calculate_next_position(state)
    render_position(next_position)
    move_after(@frame_duration)
    {:noreply, next_position}
  end

  defp render_position({{position_x, position_y}, index}) do
   Buffer.add_position(index, [position_x, position_y])
  end

  defp calculate_next_position({{position_x, position_y}, index}) do
    next_x = Enum.random(position_x..position_x+5) |> rem(50) #TODO: Use a max grid size
    {{next_x, position_y}, index} #the boids move only on x-axis for now
  end

  defp move_after(time_delay_ms) do
    Process.send_after(self(), :try_move, time_delay_ms)
  end
end
