defmodule TemperatureDemoWeb.UserSocket do
  use Phoenix.Socket

  channel "temperature:lobby", TemperatureDemoWeb.TemperatureChannel

  # Optionally, you can define transport options directly here:
  transport :websocket, Phoenix.Transports.WebSocket,
    timeout: 45_000,
    compress: false

  # This function is often used to authorize the socket connection
  def connect(_params, socket), do: {:ok, socket}
  def id(_socket), do: nil
end
