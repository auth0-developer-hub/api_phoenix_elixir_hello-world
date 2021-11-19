defmodule HelloWorldWeb.Router do
  use HelloWorldWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    plug :put_secure_browser_headers, %{
      "x-xss-protection" => "0",
      "strict-transport-security" => "max-age=31536000 ; includeSubDomains",
      "x-frame-options" => "deny",
      "content-security-policy" => "default-src 'self'; frame-ancestors 'none';",
      "cache-control" => "no-cache, no-store, max-age=0, must-revalidate",
      "server" => "undisclosed"
    }
  end

  scope "/api", HelloWorldWeb.API, as: :api do
    pipe_through :api

    scope "/messages" do
      get "/public", MessageController, :public
      get "/protected", MessageController, :protected
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
