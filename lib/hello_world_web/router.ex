defmodule HelloWorldWeb.Router do
  use HelloWorldWeb, :router

  alias HelloWorld.Auth.Permissions

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authorization do
    plug HelloWorld.Auth.Authorize
  end

  @doc """
  Authorized if the request has `read:admin-message` in the bearer token claims
  """
  pipeline :validate_permissions do
    plug HelloWorld.Auth.ValidatePermission, Permissions.read_admin_messages()
  end

  scope "/api", HelloWorldWeb.API, as: :api do
    pipe_through :api

    scope "/messages" do
      get "/public", MessageController, :public
    end
  end

  scope "/api", HelloWorldWeb.API, as: :api do
    pipe_through [:api, :authorization]

    scope "/messages" do
      get "/protected", MessageController, :protected
    end
  end

  scope "/api", HelloWorldWeb.API, as: :api do
    pipe_through [:api, :authorization, :validate_permissions]

    scope "/messages" do
      get "/admin", MessageController, :admin
    end
  end
end
