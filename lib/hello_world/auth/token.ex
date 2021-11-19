defmodule HelloWorld.Auth.Token do
  @moduledoc """
  Customizes the Joken config to verify and validate claims.
  """
  use Joken.Config, default_signer: nil

  alias HelloWorld.Auth.{Auth0Config, Auth0Strategy}

  add_hook(JokenJwks, strategy: Auth0Strategy)

  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss])
    |> add_claim("iss", nil, &(&1 == iss()))
    |> add_claim("aud", nil, &(&1 == aud()))
  end

  defp iss(), do: Auth0Config.auth0_base_url()
  defp aud(), do: Auth0Config.auth0_audience()
end
