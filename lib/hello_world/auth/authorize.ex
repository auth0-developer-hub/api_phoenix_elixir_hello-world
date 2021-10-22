defmodule HelloWorld.Auth.Authorize do
  @moduledoc """
  Plug for authorizing endpoints based on permissions
  """
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @spec init(any) :: any
  def init(default), do: default

  @doc """
  Checks whether the give role is present in the permissions claim
  """
  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, role) do
    if authorize(conn, role) do
      conn
    else
      conn
      |> put_status(403)
      |> json(%{message: "Insufficient scopes."})
      |> halt
    end
  end

  defp authorize(%{assigns: %{claims: %{"permissions" => permissions}}}, role)
       when is_list(permissions) do
    Enum.member?(permissions, role)
  end

  defp authorize(_conn, _role), do: false
end
