defmodule HelloWorldWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :hello_world

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_hello_world_key",
    signing_salt: "/zLugau6"
  ]

  # socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :hello_world,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug CORSPlug,
    origin: &HelloWorldWeb.Endpoint.allowed_origins/0,
    max_age: 86400,
    methods: ["GET"],
    headers: ["Authorization", "Content-Type"]

  plug HelloWorldWeb.Plugs.SecurityHeaders

  plug HelloWorldWeb.Router

  def allowed_origins(), do: Application.fetch_env!(:cors_plug, :origin)
end
