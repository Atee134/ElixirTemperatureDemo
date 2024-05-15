defmodule TemperatureDemoWeb.TemperatureChannel do
  use Phoenix.Channel
  require Logger

  def join("temperature:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_info(%{"group_id" => group_id, "readings" => readings}, socket) do
    readings_with_group = Enum.map(readings, fn %{sensor_id: sensor_id, temp: temp} ->
      %{"group_id" => group_id, "sensor_id" => sensor_id, "temp" => temp}
    end)
    broadcast(socket, "new_temperatures", %{"temperatures" => readings_with_group})
    {:noreply, socket}
  end

  # Catch-all clause to handle unexpected messages
  def handle_info(msg, socket) do
    Logger.error("Received unexpected message: #{inspect(msg)}")
    {:noreply, socket}
  end
end
