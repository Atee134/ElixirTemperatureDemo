defmodule TemperatureDemo.Sensors.SensorGroupServer do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.group_id))
  end

  def init(args) do
    schedule_work()
    {:ok, %{group_id: args.group_id}}
  end

  def handle_info(:work, state) do
    new_readings = for sensor_id <- 1..50, do: %{sensor_id: sensor_id, temp: Enum.random(-20..40)}
    Phoenix.PubSub.broadcast(TemperatureDemo.PubSub, "temperature:lobby", %{"group_id" => state.group_id, "readings" => new_readings})
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1_000)  # Schedule work every second
  end

  defp via_tuple(group_id) do
    {:via, Registry, {TemperatureDemo.Registry, group_id}}
  end
end
