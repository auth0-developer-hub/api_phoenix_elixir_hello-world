import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :api_phoenix_elixir_hello_world, ApiPhoenixElixirHelloWorldWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "XxtTgL9jSzBqSmaTOqUdkw4u333aJIE4Cvv+4/VSMDE9W8AuGtz0W9lnv+U/qq5v",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
