defmodule TemperatureDemoWeb.TemperatureChannel do
  use Phoenix.Channel

  def join("temperature:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_measurement", %{"temp" => _temp} = message, socket) do
    broadcast(socket, "new_temperature", message)
    {:noreply, socket}
  end
end
