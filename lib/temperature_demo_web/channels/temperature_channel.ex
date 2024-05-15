defmodule TemperatureDemoWeb.TemperatureChannel do
  use Phoenix.Channel
  require Logger

  @max_buffer_size 5000

  def join("temperature:lobby", _payload, socket) do
    Logger.debug("Client joined the temperature:lobby channel")
    {:ok, assign(socket, :buffer, [])}  # Start with an empty buffer
  end

  def handle_info(%{"sensor_id" => sensor_id, "temp" => temp}, socket) do
    buffer = socket.assigns.buffer
    updated_buffer = [%{"sensor_id" => sensor_id, "temp" => temp} | buffer]

    if length(updated_buffer) >= @max_buffer_size do
      broadcast_temperatures(socket, updated_buffer)
      {:noreply, assign(socket, :buffer, [])}  # Reset buffer after broadcasting
    else
      {:noreply, assign(socket, :buffer, updated_buffer)}
    end
  end

  defp broadcast_temperatures(socket, readings) do
    broadcast(socket, "new_temperatures", %{"temperatures" => readings})
  end

  # Catch-all clause to handle unexpected messages
  def handle_info(msg, socket) do
    Logger.error("Received unexpected message: #{inspect(msg)}")
    {:noreply, socket}
  end
end
