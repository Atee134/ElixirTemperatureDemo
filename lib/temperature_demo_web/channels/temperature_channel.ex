defmodule TemperatureDemoWeb.TemperatureChannel do
  use Phoenix.Channel
  require Logger

  @broadcast_interval 500

  def join("temperature:lobby", _payload, socket) do
    Logger.debug("Client joined the temperature:lobby channel")
    {:ok, assign(socket, :buffer, [])}
    |> start_timer()
  end

  def handle_info(%{"sensor_id" => sensor_id, "temp" => temp}, socket) do
    buffer = socket.assigns.buffer
    updated_buffer = [%{"sensor_id" => sensor_id, "temp" => temp} | buffer]
    {:noreply, assign(socket, :buffer, updated_buffer)}
  end

  def handle_info(:flush, socket) do
    broadcast_temperatures(socket, socket.assigns.buffer)
    {:noreply, assign(socket, :buffer, [])}
    |> start_timer()  # Restart the timer after flushing
  end

  defp broadcast_temperatures(socket, readings) do
    broadcast(socket, "new_temperatures", %{"temperatures" => readings})
  end

  defp start_timer(socket) do
    # Cancel any previous timer and start a new one
    Process.send_after(self(), :flush, @broadcast_interval)
    socket
  end

  # Catch-all clause to handle unexpected messages
  def handle_info(msg, socket) do
    Logger.error("Received unexpected message: #{inspect(msg)}")
    {:noreply, socket}
  end
end
