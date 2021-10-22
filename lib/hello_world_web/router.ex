defmodule HelloWorldWeb.Router do
  use HelloWorldWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authentication do
    plug HelloWorld.Auth.Authenticate
  end

  @doc """
  Authorized if the request has `read:admin-message` in the bearer token claims
  """
  pipeline :admin do
    plug HelloWorld.Auth.Authorize, "read:admin-messages"
  end

  scope "/api", HelloWorldWeb.API, as: :api do
    pipe_through :api

    scope "/messages" do
      get "/public", MessageController, :public
    end
  end

  scope "/api", HelloWorldWeb.API, as: :api do
    pipe_through [:api, :authentication]

    scope "/messages" do
      get "/protected", MessageController, :protected
    end
  end

  scope "/api", HelloWorldWeb.API, as: :api do
    pipe_through [:api, :authentication, :admin]

    scope "/messages" do
      get "/admin", MessageController, :admin
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: HelloWorldWeb.Telemetry
    end
  end
end
