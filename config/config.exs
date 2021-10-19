# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :hello_world, HelloWorldWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: HelloWorldWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: HelloWorld.PubSub,
  live_view: [signing_salt: "wNbO3T3e"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :cors_plug,
  origin: [System.get_env("CLIENT_ORIGIN_URL", "http://localhost:4040")]

config :hello_world,
  auth0_domain: System.get_env("AUTH0_DOMAIN"),
  auth0_audience: System.get_env("AUTH0_AUDIENCE")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
