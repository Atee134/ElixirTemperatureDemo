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

    sensor_group_children = for group_id <- 1..20 do
      Supervisor.child_spec({TemperatureDemo.Sensors.SensorGroupServer, %{group_id: group_id}},
        id: {:sensor_group, group_id})  # Unique ID for each child
    end

    children = base_children ++ sensor_group_children

    opts = [strategy: :one_for_one, name: TemperatureDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TemperatureDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
