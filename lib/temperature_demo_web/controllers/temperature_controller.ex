defmodule TemperatureDemoWeb.TemperatureController do
  use TemperatureDemoWeb, :controller

  def index(conn, _params) do
    render(conn, TemperatureDemoWeb.TemperatureHTML, "index.html")
  end
end
