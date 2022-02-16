defmodule HelloWorldWeb.Router do
  use HelloWorldWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authorization do
    plug HelloWorld.Auth.Authorize
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
      get "/admin", MessageController, :admin
    end
  end
end
