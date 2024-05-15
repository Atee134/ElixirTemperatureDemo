defmodule TemperatureDemoWeb.TemperatureChannelTest do
  use TemperatureDemoWeb.ChannelCase

  setup do
    {:ok, socket} = connect(TemperatureDemoWeb.UserSocket, %{})
    {:ok, _, socket} = subscribe_and_join(socket, "temperature:lobby", %{})
    {:ok, socket: socket}
  end

  test "joins the channel successfully", %{socket: socket} do
    assert socket.topic == "temperature:lobby"
  end

  test "broadcasts new temperature when a measurement is received", %{socket: socket} do
    push(socket, "new_measurement", %{"temp" => 22})

    # Using assert_broadcast to catch the broadcast with exact matching.
    assert_broadcast("new_temperature", %{"temp" => 22})
  end
end
