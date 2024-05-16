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
    {new_temp, new_rate} = update_temperature(state[:temp], state[:rate], state[:min_temp], state[:max_temp])

    # Update the state with the new temperature and potentially new rate
    updated_state = Map.put(state, :temp, new_temp)
    updated_state = Map.put(updated_state, :rate, new_rate)

    # Broadcast the new temperature
    broadcast_new_temperature(state[:sensor_id], new_temp)

    # Reschedule the next tick
    schedule_tick()

    {:noreply, updated_state}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, 500)  # Send a tick every second
  end

  defp update_temperature(temp, rate, min, max) do
    new_temp = temp + rate
    cond do
      new_temp < min -> {min, rate * -1}  # Reverse the rate if temperature goes below minimum
      new_temp > max -> {max, rate * -1}  # Reverse the rate if temperature goes above maximum
      true -> {new_temp, rate}  # Normal case where temperature is within limits
    end
  end

  defp broadcast_new_temperature(sensor_id, temp) do
    Phoenix.PubSub.broadcast(TemperatureDemo.PubSub, "temperature:lobby", %{"sensor_id" => sensor_id, "temp" => temp})
  end

  defp via_tuple(sensor_id) do
    {:via, Registry, {TemperatureDemo.Registry, sensor_id}}
  end
end
