defmodule TemperatureDemo.Sensors.Sensor do
  use GenServer
  require Logger

  # Starts a new sensor process
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args[:sensor_id]))
  end

  # Initializes the sensor with the given state
  def init(state) do
    schedule_tick()
    {:ok, state}
  end

  # Handles the periodic update based on the tick
  def handle_info(:tick, state) do
    new_temp = state[:temp] + state[:rate]
    new_temp = apply_limits(new_temp, state[:min_temp], state[:max_temp])

    # Update the state with the new temperature
    updated_state = Map.put(state, :temp, new_temp)

    # Broadcast the new temperature
    broadcast_new_temperature(state[:sensor_id], new_temp)

    # Reschedule the next tick
    schedule_tick()

    {:noreply, updated_state}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, 1000)  # Send a tick every second
  end

  defp apply_limits(temp, min, max) do
    cond do
      temp < min -> min
      temp > max -> max
      true -> temp
    end
  end

  defp broadcast_new_temperature(sensor_id, temp) do
    Phoenix.PubSub.broadcast(TemperatureDemo.PubSub, "temperature:lobby", %{"sensor_id" => sensor_id, "temp" => temp})
  end

  defp via_tuple(sensor_id) do
    {:via, Registry, {TemperatureDemo.Registry, sensor_id}}
  end
end
