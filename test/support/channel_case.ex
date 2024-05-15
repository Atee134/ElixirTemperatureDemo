defmodule TemperatureDemoWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      alias TemperatureDemoWeb.UserSocket
      # Explicitly set the endpoint module attribute
      @endpoint TemperatureDemoWeb.Endpoint
    end
  end
end
