import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hello_world, HelloWorldWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "zYbxYEMr1b7/jHfdjIcKU4ihM7RbA1wcwKUXy0EwW4EwdRj/YAsX5v2g2EkA9FK4",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
