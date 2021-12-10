defmodule HelloWorld.Auth.Auth0Config do
  def auth0_audience, do: Application.get_env(:hello_world, :auth0_audience)

  def auth0_domain do
    auth0_domain = Application.get_env(:hello_world, :auth0_domain)
    uri = URI.parse(auth0_domain)

    case uri do
      %URI{scheme: nil} -> "https://#{uri.path}/"
      %URI{scheme: "http"} -> "https://#{uri.host}/"
      %URI{scheme: "https"} -> uri
    end
  end
end
