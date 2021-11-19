defmodule HelloWorld.Auth.Permissions do
  @moduledoc """
  List of permissions for the API.
  """

  def read_admin_messages do
    MapSet.new(["read:admin-messages"])
  end
end
