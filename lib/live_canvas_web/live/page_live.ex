defmodule LiveCanvasWeb.PageLive do
  use LiveCanvasWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:upload_file, nil)
      |> assign(:clip_images, [])
      |> allow_upload(
        :image,
        accept: :any,
        chunk_size: 6400_000,
        progress: &handle_progress/3,
        auto_upload: true
      )
    }
  end

  def handle_progress(:image, _entry, socket) do
    {upload_file, mime} =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        {:ok, file} = File.read(path)

        {file, entry.client_type}
      end)
      |> List.first()

    {
      :noreply,
      socket
      |> assign(:upload_file, upload_file)
      |> push_event("draw", %{src: Base.encode64(upload_file), mime: mime})
    }
  end

  def handle_event("drew", %{"data" => pixel}, socket) do
    pixel =
      pixel
      |> Map.to_list()
      |> Enum.map(fn {k, v} -> {String.to_integer(k), v} end)
      |> Enum.sort()
      |> Enum.map(fn {_k, v} -> v end)
      |> Nx.tensor()

    {row} = Nx.shape(pixel)
    pixel = pixel |> Nx.reshape({div(row, 4), 4})
    {:noreply, socket |> assign(:org_pixel, pixel)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove", _params, socket) do
    {
      :noreply,
      socket
      |> assign(upload_file: nil)
      |> push_event("remove", %{})
    }
  end

  @impl true
  def handle_event("invert", _params, %{assigns: %{org_pixel: org_pixel}} = socket) do
    pixel = LiveCanvas.Worker.invert(org_pixel)
    {:noreply, push_event(socket, "manipulate", %{pixel: pixel})}
  end

  @impl true
  def handle_event("grayscale", _params, %{assigns: %{org_pixel: org_pixel}} = socket) do
    pixel = LiveCanvas.Worker.grayscale(org_pixel)
    {:noreply, push_event(socket, "manipulate", %{pixel: pixel})}
  end
end
