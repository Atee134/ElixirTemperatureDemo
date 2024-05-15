defmodule TemperatureDemoWeb.TemperatureChannel do
  use Phoenix.Channel

  def join("temperature:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_info(%{"temp" => temp}, socket) do
    broadcast(socket, "new_temperature", %{"temp" => temp})
    {:noreply, socket}
  end
end
