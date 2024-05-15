defmodule TemperatureDemo.Repo do
  use Ecto.Repo,
    otp_app: :temperature_demo,
    adapter: Ecto.Adapters.Postgres
end
