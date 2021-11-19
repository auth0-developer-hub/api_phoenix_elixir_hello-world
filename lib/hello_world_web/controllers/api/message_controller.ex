defmodule HelloWorldWeb.API.MessageController do
  use HelloWorldWeb, :controller

  @spec public(Plug.Conn.t(), any) :: Plug.Conn.t()
  def public(conn, _params) do
    message = "The API doesn't require an access token to share this message."
    json(conn, %{message: message})
  end

  @spec protected(Plug.Conn.t(), any) :: Plug.Conn.t()
  def protected(conn, _params) do
    message = "The API successfully validated your access token."
    json(conn, %{message: message})
  end

  @spec admin(Plug.Conn.t(), any) :: Plug.Conn.t()
  def admin(conn, _params) do
    message = "The API successfully recognized you as an admin."
    json(conn, %{message: message})
  end
end
