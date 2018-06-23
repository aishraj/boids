defmodule Boids.Renderer.Tui do
  use GenServer
  alias IO.ANSI

  #
  # GenServer API
  #
  def start_link(grid) do
    GenServer.start_link(__MODULE__, [grid])
  end

  #
  # GenServer Callbacks
  #
  def init(state) do
    print_grid(state)
    {:ok, state}
  end

  def handle_info({:render_grid, new_state}, state) do
    if new_state != state, do: print_grid(new_state)

    {:noreply, new_state}
  end

  #
  # Other functions
  #
  defp clear_screen do
    IO.write([IO.ANSI.clear(), IO.ANSI.home()])
    IO.write([?\r, ?\n])
  end

  defp print_grid(state) do
    clear_screen()
    IO.write(format_grid(state))
  end

  defp format_grid(grid) do
    # TODO: Read size from config
    Enum.chunk(grid, 50)
    |> format_rows
  end

  #
  # Private API
  #
  defp format_rows(grid_rows) do
    grid_rows
    |> Enum.map(&[" ", format_grid_row(&1), "\r\n"])
  end

  defp format_grid_row(row) do
    Enum.map(row, &format_grid_cell/1)
  end

  defp format_grid_cell(cell) do
    case cell do
      ?_ -> ANSI.format([" ", :bright, :black, ?/])
      ?* -> ANSI.format([" ", :bright, :blue, cell])
      _ -> [" ", cell]
    end
  end
end
