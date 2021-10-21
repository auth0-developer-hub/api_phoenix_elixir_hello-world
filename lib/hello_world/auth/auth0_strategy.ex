defmodule HelloWorld.Auth.Auth0Strategy do
  @moduledoc """
  Defines a custom Strategy for JokenJwks using a custom jwks domain.
  """
  use JokenJwks.DefaultStrategyTemplate

  def init_opts(opts) do
    Keyword.merge(opts, jwks_url: jwks_url())
  end

  defp jwks_url do
    Application.get_env(:hello_world, :auth0_domain) <> ".well-known/jwks.json"
  end
end
