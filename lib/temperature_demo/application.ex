defmodule TemperatureDemo.Application do
  use Application

  @impl true
  def start(_type, _args) do
    base_children = [
      TemperatureDemoWeb.Telemetry,
      TemperatureDemo.Repo,
      {DNSCluster, query: Application.get_env(:temperature_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TemperatureDemo.PubSub},
      {Finch, name: TemperatureDemo.Finch},
      TemperatureDemoWeb.Endpoint,
      {Registry, keys: :unique, name: TemperatureDemo.Registry}  # Corrected Registry definition
    ]

    sensor_children = for sensor_id <- 1..5000 do
      initial_temp = Enum.random(-25..40)
      rate = Enum.random(-2..2)
      max_temp = Enum.random(40..50)
      min_temp = Enum.random(-30..-15)

      Supervisor.child_spec(
        {TemperatureDemo.Sensors.Sensor, %{sensor_id: sensor_id, temp: initial_temp, rate: rate, max_temp: max_temp, min_temp: min_temp}},
        id: {:sensor, sensor_id}  # Ensure unique ID for each sensor
      )
    end

    children = base_children ++ sensor_children

    opts = [strategy: :one_for_one, name: TemperatureDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TemperatureDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
