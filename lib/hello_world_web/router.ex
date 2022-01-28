defmodule HelloWorldWeb.Router do
  use HelloWorldWeb, :router
  use Plug.ErrorHandler

  @headers %{
    "x-xss-protection" => "0",
    "strict-transport-security" => "max-age=31536000; includeSubDomains",
    "x-frame-options" => "deny",
    "content-security-policy" => "default-src 'self'; frame-ancestors 'none';",
    "cache-control" => "no-cache, no-store, max-age=0, must-revalidate",
    "server" => "undisclosed"
  }

  alias HelloWorld.Auth.Permissions

  pipeline :api do
    plug :accepts, ["json"]

    plug :put_secure_browser_headers, @headers
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

  @impl Plug.ErrorHandler
  def handle_errors(conn, _assings) do
    conn
    |> put_view(HelloWorldWeb.ErrorView)
    |> put_secure_browser_headers(@headers)
    |> render("404.json")
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
