defmodule HelloWorldWeb.Router do
  use HelloWorldWeb, :router
  use Plug.ErrorHandler

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HelloWorldWeb.API, as: :api do
    pipe_through :api

    scope "/messages" do
      get "/public", MessageController, :public
      get "/protected", MessageController, :protected
      get "/admin", MessageController, :admin
    end
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, _assings) do
    conn
    |> put_view(HelloWorldWeb.ErrorView)
  end
end
