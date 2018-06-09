defmodule Boids.Heatmap do
  use GenServer
  require Logger

  #API
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:heat_stuff, _from, state) do
    {:reply, state}
  end
end
