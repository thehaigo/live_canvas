defmodule LiveCanvas.Worker do
  use GenServer
  import Nx.Defn

  @name __MODULE__
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, []}
  end

  def grayscale(pixel) do
    GenServer.call(@name, {:grayscale, pixel})
  end

  def invert(pixel) do
    GenServer.call(@name, {:invert, pixel})
  end

  def handle_call({:grayscale, pixel}, _from, state) do
    gray_pixel = gray(pixel)
    rgb =
      gray_pixel
      |> Nx.to_flat_list()
      |> Enum.map(fn avg -> [avg, avg, avg] end)
      |> Nx.tensor()

    a = Nx.slice_axis(pixel, 4, 1, -1)
    pixel =
      Nx.concatenate([rgb, a], axis: -1)
      |> Nx.to_flat_list()
    {:reply, pixel, state}
  end

  def handle_call({:invert, pixel}, _from, state) do
    rgb = reverse(pixel)
    a = Nx.slice_axis(pixel, 4, 1, -1)
    pixel =
      Nx.concatenate([rgb, a], axis: -1)
      |> Nx.to_flat_list()
    {:reply, pixel, state}
  end

  defn reverse(pixel) do
    pixel
    |> Nx.slice_axis(0, 3, -1)
    |> Nx.map(fn x -> 255 - x end)
  end

  @defn_compiler {EXLA, [platform: :host]}
  defn gray(pixel) do
    pixel
    |> Nx.slice_axis(0, 3, -1)
    |> Nx.mean(axes: [-1])
    |> Nx.round()
  end
end
