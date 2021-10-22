defmodule HelloWorld.Auth.Authenticate do
  @moduledoc """
  Plug for authenticating endpoints using Bearer authorization token.
  """
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias HelloWorld.Auth.Token

  @spec init(any) :: any
  def init(default), do: default

  @doc """
  Extracts the Bearer token from the authorization header and verifies the claims.
  """
  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _default) do
    with {:ok, token} when is_binary(token) <- get_token(conn),
         {:ok, claims} <- Token.verify_and_validate(token) do
      conn = assign(conn, :claims, claims)
      conn
    else
      {:error, :missing_token} ->
        conn
        |> put_status(401)
        |> json(%{message: "No authorization token was found"})
        |> halt

      _error ->
        conn
        |> put_status(401)
        |> json(%{message: "Unauthorized"})
        |> halt
    end
  end

  defp get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      [token] -> {:ok, token}
      _ -> {:error, :missing_token}
    end
  end
end
