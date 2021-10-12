defmodule ApiPhoenixElixirHelloWorld.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ApiPhoenixElixirHelloWorldWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ApiPhoenixElixirHelloWorld.PubSub},
      # Start the Endpoint (http/https)
      ApiPhoenixElixirHelloWorldWeb.Endpoint
      # Start a worker by calling: ApiPhoenixElixirHelloWorld.Worker.start_link(arg)
      # {ApiPhoenixElixirHelloWorld.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ApiPhoenixElixirHelloWorld.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ApiPhoenixElixirHelloWorldWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
