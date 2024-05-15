defmodule TemperatureDemo.SensorSimulator do
  use GenServer

  alias TemperatureDemoWeb.Endpoint
  alias Phoenix.PubSub

  # Starts the GenServer
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Initialize the GenServer state
  def init(:ok) do
    # Schedule work to be performed every second
    schedule_work()
    {:ok, %{}}
  end

  def handle_info(:work, state) do
    temp = Enum.random(15..35)
    # Broadcast directly the temperature without the extra wrapping
    Phoenix.PubSub.broadcast(TemperatureDemo.PubSub, "temperature:lobby", %{"temp" => temp})
    schedule_work()
    {:noreply, state}
  end

  # Helper function to schedule work every 1000 milliseconds (1 second)
  defp schedule_work do
    Process.send_after(self(), :work, 1_000)
  end
end
