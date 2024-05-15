defmodule TemperatureDemoWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  channel "temperature:lobby", TemperatureDemoWeb.TemperatureChannel

  transport :websocket, Phoenix.Transports.WebSocket,
    timeout: 45_000,
    compress: false

  # Enhance the connect function with logging
  def connect(params, socket) do
    Logger.info("UserSocket connected with params: #{inspect(params)}")
    {:ok, socket}
  end

  # Add logging to help trace the ID used for the socket, if applicable
  def id(socket) do
    # Log the details if you need to trace what ID is being used.
    # Adjust depending on your needs; here just an example to log the assigns if ever needed:
    Logger.debug("Socket ID requested, assigns: #{inspect(socket.assigns)}")
    nil  # Assuming no specific ID is required for your use case
  end
end
