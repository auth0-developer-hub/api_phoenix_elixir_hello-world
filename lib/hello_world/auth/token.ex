defmodule HelloWorld.Auth.Token do
  @moduledoc """
  Customises the Joken config to verify and validate claims.
  """
  use Joken.Config, default_signer: nil

  alias HelloWorld.Auth.Strategy

  add_hook(JokenJwks, strategy: Strategy)

  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss])
    |> add_claim("iss", nil, &(&1 == iss()))
    |> add_claim("aud", nil, &(&1 == aud()))
  end

  defp iss(), do: Application.get_env(:hello_world, :auth0_domain)
  defp aud(), do: Application.get_env(:hello_world, :auth0_audience)
end
