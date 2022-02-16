defmodule HelloWorldWeb.Plugs.SecurityHeaders do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    merge_resp_headers(conn, [
      {"cache-control", "no-cache, no-store, max-age=0, must-revalidate"},
      {"content-security-policy", "default-src 'self'; frame-ancestors 'none';"},
      {"server", "undisclosed"},
      {"strict-transport-security", "max-age=31536000; includeSubDomains"},
      {"x-content-type-options", "nosniff"},
      {"x-frame-options", "deny"},
      {"x-xss-protection", "0"}
    ])
  end
end
