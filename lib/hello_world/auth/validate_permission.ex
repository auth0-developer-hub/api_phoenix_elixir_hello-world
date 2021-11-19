defmodule HelloWorld.Auth.ValidatePermission do
  @moduledoc """
  Plug for validating permissions on endpoints
  """
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2, put_view: 2, render: 3]

  @spec init(any) :: any
  def init(default), do: default

  @doc """
  Checks whether the give permission is present in the permissions claim
  """
  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, authorized_permissions) do
    if validate_permission(conn, authorized_permissions) do
      conn
    else
      handle_error_response(conn, %{})
    end
  end

  defp validate_permission(
         %{assigns: %{claims: %{"permissions" => token_permissions}}},
         authorized_permissions
       )
       when is_list(token_permissions) do
    not MapSet.disjoint?(MapSet.new(token_permissions), authorized_permissions)
  end

  defp validate_permission(_conn, _permission), do: false

  defp handle_error_response(conn, error) do
    conn
    |> put_status(403)
    |> put_view(HelloWorldWeb.ErrorView)
    |> render("403.json", %{})
    |> halt()
  end
end
