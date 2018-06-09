defmodule Boids.Animator do
  use GenServer
  require Logger
  require Poison
  alias Boids.Buffer

  #API
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(arg) do
    Process.send(self(), :initialize_simulation, arg)
    {:ok, []}
  end

  def handle_info(:initialize_simulation, _state) do
    Logger.info("Starting birds now......")
    create_birds(Application.get_env(:boids, :number_boids))
    render_json(Application.get_env(:boids, :frame_duration))
    {:noreply, []}
  end

  def handle_info(:render_json, _state ) do
    render_json(Application.get_env(:boids, :frame_duration))
    {:noreply, []}
  end


  defp create_birds(n) do
    (0..n-1)
    |> Enum.shuffle
    |> Enum.with_index
    |> Enum.each(fn {position, index} -> new_bird(position, index) end)
  end

  defp new_bird(pos_x, index) do
    spec = %{id: Boid, start: {Boids.Boid, :start_link, [{pos_x, index}]}}
    DynamicSupervisor.start_child(Boids.DynamicSupervisor, spec)
  end

  defp render_json(time_delay_ms) do
    #Hack: For now just using IO.puts to "render the item on screen as json"
    #TODO: Emit this to a websocket
    Buffer.get_all_positions |> Poison.encode! |> IO.puts
    Process.send_after(self(), :render_json, time_delay_ms)
  end

end
