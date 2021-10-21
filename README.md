# Hello World API: Phoenix + Elixir Sample

You can use this sample project to learn how to secure a simple Phoenix API server using Auth0.

The `starter` branch offers a working API server that exposes three public endpoints. Each endpoint returns a different type of message: public, protected, and admin.

The goal is to use Auth0 to only allow requests that contain a valid access token in their authorization header to access the protected and admin data. Additionally, only access tokens that contain a `read:admin-messages` permission should access the admin data, which is referred to as [Role-Based Access Control (RBAC)](https://auth0.com/docs/authorization/rbac/).

## Setup

### Install Elixir

If needed, install Elixir by following the [official installation guide](http://elixir-lang.org/install.html).

Once complete, you can verify your Elixir installation by running `elixir -v`, which prints the version of Elixir present in your system:

```bash
elixir -v

Erlang/OTP 24 [erts-12.1.1] [source] [64-bit] [smp:48:48] [ds:48:48:10] [async-threads:1] [jit]
Elixir 1.12.3 (compiled with Erlang/OTP 24)
```

### Install the Hex package manager

If needed, install the `hex` package manager:

```bash
mix local.hex
```

### Install project dependencies

You can fetch and install dependencies by running the following commmand:

```bash
mix deps.get
```

## Define Environment Variables

Create a `.env` file under the root project directory and populate it with the following environment variables:

```bash
PORT=6060
CLIENT_ORIGIN_URL=http://localhost:4040
SECRET_KEY_BASE=your_secret_key
AUTH0_DOMAIN=auth0_domain
AUTH0_AUDIENCE=auth0_audience

```

| Variable           | Default                 | Description                                     |
| ------------------ | ----------------------- | ----------------------------------------------- |
|  PORT              | 6060                    | Port the application accepts requests           |
|  CLIENT_ORIGIN_URL | http://localhost:4040   | Origin from which API accepts requests          |
|  SECRET_KEY_BASE   |                         | used to sign/encrypt cookies and other secrets. |
|  AUTH0_DOMAIN      |                         | Auth0 Domain                                    |
|  AUTH0_AUDIENCE    |                         | Auth0 Audience.                                 |

You can generate `SECRET_KEY_BASE` by executing the following command as [recommended by the Phoenix framework](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Secret.html):
 `mix phx.gen.secret`

## Project Configuration

### CORS

You'll restrict the API server to only serve requests from a client with the origin whose value matches the `CLIENT_ORIGIN_URL` environment variable.

You can implement such restriction by enabling CORS support using the [`cors_plug` package](https://github.com/mschae/cors_plug).

Add `cors_plug` to the list of dependencies in the `mix.exs` file:

```diff
  defp deps do
    [
      {:phoenix, "~> 1.6.2"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
-     {:plug_cowboy, "~> 2.5"}
+     {:plug_cowboy, "~> 2.5"},
+     {:cors_plug, "~> 2.0"}
    ]
  end
```

Then, run the following command to install that new dependency:

```bash
mix deps.get
```

Once `cors_plug` is installed, add set up CORS in the project by adding the following lines to `config/runtime.exs`:

```diff
+config :cors_plug,
+  origin: System.fetch_env!("CLIENT_ORIGIN_URL")
```

Next, open `lib/hello_world_web/endpoint.ex` and add the `CORSPlug` plug above the `Router` plug:

```diff
   plug Plug.Session, @session_options
+  plug CORSPlug
   plug HelloWorldWeb.Router
```

## Authorization

In this section, we will secure 2 endpoints by adding authentication using JWT access tokens.

We will start by adding the following packages to our `mix.exs` file.

* [joken](https://hexdocs.pm/joken/readme.html)
* [joken_jwks](https://hexdocs.pm/joken_jwks/readme.html)

Open `mix.exs` file and add the following:

```diff
  defp deps do
    [
      {:phoenix, "~> 1.6.2"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
+     {:cors_plug, "~> 2.0"},
+     {:joken, "~> 2.4"},
+     {:joken_jwks, "~> 1.5"}
    ]
  end
```

Run `mix deps.get` to install the newly added packages.

Next, we will add Auth0 domain and audience to our configuration. Open `config/config.exs` and add the following

```diff
+ config :hello_world,
+  auth0_domain: System.get_env("AUTH0_DOMAIN"),
+  auth0_audience: System.get_env("AUTH0_AUDIENCE")

```

We will now create a custom strategy for `JokenJwks` so that we can use our Auth0 domain.

Create a new file `lib/hello_world/auth/strategy.ex` and add the following

```elixir
defmodule HelloWorld.Auth.Strategy do
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
```

This module implements a custom strategy for `JokenJwks`.

In the `init_opts/1` callback, we override the `jwks_url` by passing `jwks_url` function,
which retrieves the Auth0 domain that we configured above, and points to the JWKS endpoint of our tenant.

References:
[JokenJwks Strategy](https://hexdocs.pm/joken_jwks/JokenJwks.DefaultStrategyTemplate.html#content)
[JSON Web Key Sets](https://auth0.com/docs/security/tokens/json-web-tokens/json-web-key-sets)

Now, we have to add our custom strategy to our application's supervision tree.

Open `lib/hello_world/application.ex` and add `HelloWorld.Auth.Strategy` to the list of `children` inside the `start/2` function.

```diff
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HelloWorldWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HelloWorld.PubSub},
      # Start the Endpoint (http/https)
+     HelloWorldWeb.Endpoint,
      # Start a worker by calling: HelloWorld.Worker.start_link(arg)
      # {HelloWorld.Worker, arg}
+     HelloWorld.Auth.Strategy
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloWorld.Supervisor]
    Supervisor.start_link(children, opts)
  end
```

References:
[Supervisor and Application](https://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html)

Now, let's implement a module that verifies and validates our JWT token.

Create a new file `lib/hello_world/auth/token.ex` with the following

```elixir
defmodule HelloWorld.Auth.Token do
  @moduledoc """
  Customizes the Joken config to verify and validate claims.
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
```

Explanation:

```elixir
use Joken.Config, default_signer: nil
```

Here, we are customizing the `Joken.Config` and setting `default_signer` to nil, so that we can override the signer in the next step.

```elixir
add_hook(JokenJwks, strategy: Strategy)
```
Since Auth0 is our token signing provider instead of our application, we will utilize the `add_hook` function callback to use the custom strategy we created in the step above.

```elixir
  def token_config do
    default_claims(skip: [:aud, :iss])
    |> add_claim("iss", nil, &(&1 == iss()))
    |> add_claim("aud", nil, &(&1 == aud()))
  end
```

We will implement a custom `token_config` callback, where we verify that the `issuer` and the `audience` of the token is the same as the issuer and audience of our application.

References:
[Overriding token_config/0](https://hexdocs.pm/joken/configuration.html#overriding-token_config-0)

Now, that we have added a module to verify and validate the JWT token, let's add a `Plug` that we can use to verify the access token that gets passed to the request header.

Create a new file `lib/hello_world/auth/authenticate.ex` with

```elixir
defmodule HelloWorld.Auth.Authenticate do
  @moduledoc """
  Plug for authenticating endpoints using Bearer authorization token.
  """
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias HelloWorld.Auth.Token

  @spec init(any) :: any
  def init(default), do: default

  @doc """
  Extracts the Bearer token from the authorization header and verifies the claims.
  """
  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _default) do
    with token when is_binary(token) <- get_token(conn),
         {:ok, _claims} <- Token.verify_and_validate(token) do
      conn
    else
      _ ->
        conn
        |> put_status(401)
        |> json(%{message: "Unauthorized"})
        |> halt
    end
  end

  defp get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      [token] -> token
      _ -> nil
    end
  end
end
```

Explanation:
We implement a module using Plug behaviour, which intercepts the `conn` struct, extracts the `authorization` header and verifies and validates the token using `HelloWorld.Auth.Token` we created above.

`get_token/1` function extracts the headers using `get_req_header/2` function, and extracts the token from `Bearer token`
We then pass the token to `Token.verify_and_validate(token)` which would return a `{:ok, _claims}` tuple or an `{:error, error}` tuple.
In case of an error, we halt the connection and respond with `401` status code and `message: "Unauthorized"` message.

References:
[Plug Documentation](https://hexdocs.pm/plug/readme.html)


Let's add this plug to our `lib/hello_world_web/router.ex` file.

We will start by adding a new pipeline named `authentication`

```diff
+  pipeline :authentication do
+    plug HelloWorld.Auth.Authenticate
+  end
```

Now, let's update our routes, and move `/api/messages/protected` and `/api/messages/admin` inside the `authentication` pipeline

```elixir
  scope "/api", HelloWorldWeb.API, as: :api do
    pipe_through [:api, :authentication]

    scope "/messages" do
      get "/protected", MessageController, :protected
      get "/admin", MessageController, :admin
    end
  end
```

Any requests that are passed through this pipeline will utilize the Plug that we created above and will verify and validate the access token that is passed.

References:
[Phoenix pipeline](https://hexdocs.pm/phoenix/routing.html#pipelines)

## Run the Project in Development Mode

Start your Phoenix API server by running the following command:

```bash
mix phx.server
```

You can also run the server inside IEx by running the following command instead:

```bash
iex -S mix phx.server
```

You can then make requests to `http://localhost:6060/api/message/type` to test that your API server is working.

## API Endpoints

The API server defines the following endpoints:

### 🔓 Get public message

```bash
$ http localhost:6060/api/messages/public
HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 76
content-type: application/json; charset=utf-8
date: Thu, 14 Oct 2021 11:48:50 GMT
server: Cowboy
x-request-id: Fq3jRiya7fLA6_AAAAAt

{
    "message": "The API doesn't require an access token to share this message."
}
```

### 🔓 Get protected message

* Without access token

```bash
$ http localhost:6060/api/messages/protected

HTTP/1.1 401 Unauthorized
cache-control: max-age=0, private, must-revalidate
content-length: 26
content-type: application/json; charset=utf-8
date: Thu, 21 Oct 2021 13:19:30 GMT
server: Cowboy
x-request-id: FrAOSNARDSB6H3UAAAQZ

{
    "message": "Unauthorized"
}
```

* With invalid access token

```bash
$ http localhost:6060/api/messages/protected "Authorization: Bearer invalid-token"

HTTP/1.1 401 Unauthorized
cache-control: max-age=0, private, must-revalidate
content-length: 26
content-type: application/json; charset=utf-8
date: Thu, 21 Oct 2021 13:20:31 GMT
server: Cowboy
x-request-id: FrAOVvBgC0MYsOEAAASZ

{
    "message": "Unauthorized"
}
```

* With invalid header

```bash
$ http localhost:6060/api/messages/protected "Auth: Bearer invalid-token"         

HTTP/1.1 401 Unauthorized
cache-control: max-age=0, private, must-revalidate
content-length: 26
content-type: application/json; charset=utf-8
date: Thu, 21 Oct 2021 13:21:11 GMT
server: Cowboy
x-request-id: FrAOYGKbE1XYCqYAAAWY

{
    "message": "Unauthorized"
}
```

* With valid header and token

Bearer token is set in an env variable name `AUTH0_BEARER_TOKEN` for testing.

```
$ http localhost:6060/api/messages/protected "Authorization: Bearer $AUTH0_BEARER_TOKEN"

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 63
content-type: application/json; charset=utf-8
date: Thu, 21 Oct 2021 13:21:57 GMT
server: Cowboy
x-request-id: FrAOawV7yQxs8wkAAASB

{
    "message": "The API successfully validated your access token."
}
```

### 🔓 Get admin message


* Without access token

```bash
$ http localhost:6060/api/messages/admin

HTTP/1.1 401 Unauthorized
cache-control: max-age=0, private, must-revalidate
content-length: 26
content-type: application/json; charset=utf-8
date: Thu, 21 Oct 2021 13:19:30 GMT
server: Cowboy
x-request-id: FrAOSNARDSB6H3UAAAQZ

{
    "message": "Unauthorized"
}
```

* With invalid access token

```bash
$ http localhost:6060/api/messages/admin "Authorization: Bearer invalid-token"

HTTP/1.1 401 Unauthorized
cache-control: max-age=0, private, must-revalidate
content-length: 26
content-type: application/json; charset=utf-8
date: Thu, 21 Oct 2021 13:20:31 GMT
server: Cowboy
x-request-id: FrAOVvBgC0MYsOEAAASZ

{
    "message": "Unauthorized"
}
```

* With invalid header

```bash
$ http localhost:6060/api/messages/admin "Auth: Bearer invalid-token"         

HTTP/1.1 401 Unauthorized
cache-control: max-age=0, private, must-revalidate
content-length: 26
content-type: application/json; charset=utf-8
date: Thu, 21 Oct 2021 13:21:11 GMT
server: Cowboy
x-request-id: FrAOYGKbE1XYCqYAAAWY

{
    "message": "Unauthorized"
}
```

* With valid header and token

Bearer token is set in an env variable name `AUTH0_BEARER_TOKEN` for testing.

```bash
$ http localhost:6060/api/messages/admin "Authorization: Bearer $AUTH0_BEARER_TOKEN"

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 63
content-type: application/json; charset=utf-8
date: Thu, 21 Oct 2021 13:21:57 GMT
server: Cowboy
x-request-id: FrAOawV7yQxs8wkAAASB

{
    "message": "The API successfully recognized you as an admin."
}
```
