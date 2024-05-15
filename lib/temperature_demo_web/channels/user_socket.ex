defmodule TemperatureDemoWeb.UserSocket do
  use Phoenix.Socket

  channel "temperature:lobby", TemperatureDemoWeb.TemperatureChannel

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
