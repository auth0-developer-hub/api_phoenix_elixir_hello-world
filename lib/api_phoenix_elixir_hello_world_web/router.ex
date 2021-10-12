defmodule ApiPhoenixElixirHelloWorldWeb.Router do
  use ApiPhoenixElixirHelloWorldWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApiPhoenixElixirHelloWorldWeb.API, as: :api do
    pipe_through :api

    get "/messages/public", MessageController, :public
    get "/messages/protected", MessageController, :protected
    get "/messages/admin", MessageController, :admin
  end
end
