# api_phoenix_elixir_hello-world

A sample elixir phoenix api project to demonstrate securing your app using Auth0

## Setup

### Install Elixir

Install elixir by following the installation guide [here](http://elixir-lang.org/install.html)

Installation can be verified by running `elixir -v` which would print the elixir version.

```
elixir -v

Erlang/OTP 24 [erts-12.1.1] [source] [64-bit] [smp:48:48] [ds:48:48:10] [async-threads:1] [jit]
Elixir 1.12.3 (compiled with Erlang/OTP 24)
```


### Installing Hex package manager

After installing elixir for the first time, we will need to install hex - the package manager.

```
mix local.hex
```

### Installing dependencies

Once we have Elixir installed, we can fetch and install dependencies by running:

```
mix deps.get
```

## Environment Variables

Create a `.env` file under the root project directory and populate it with the following environment variables


| Variable           | Default                 | Description                            |
| ------------------ | ----------------------- | -------------------------------------- |
|  PORT              | 6060                    | Port the application accepts requests  |
|  CLIENT_ORIGIN_URL | http://localhost:4040   | Origin from which API accepts requests |

## Configuration

### CORS

We will allow the API server to connect from clients defined using the env variable `CLIENT_ORIGIN_URL`.
To enable CORS support, we will use the package [`cors_plug`](https://github.com/mschae/cors_plug)

Add `cors_plug` to the list of dependencies in `mix.exs` file.

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

And run `mix deps.get`

Once the dependency is installed, we need to add the CORS config by adding the following likes to `config/config.exs`

```diff
+config :cors_plug,
+  origin: [System.get_env("CLIENT_ORIGIN_URL", "http://localhost:4040")]
```

And add the plug `CORSPlug` above the `Router` in the endpoint config located at `lib/api_phoenix_elixir_hello_world_web/endpoint.ex`

```diff
   plug Plug.Session, @session_options
+  plug CORSPlug
   plug ApiPhoenixElixirHelloWorldWeb.Router
```

## Development


Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:6060`](http://localhost:6060) from your browser.

## API Endpoints

The API server defines the following endpoints:

### 🔓 Get public message

```
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

```
$ http localhost:6060/api/messages/protected

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 63
content-type: application/json; charset=utf-8
date: Thu, 14 Oct 2021 11:49:33 GMT
server: Cowboy
x-request-id: Fq3jUEh_MfaUQEUAAAAB

{
    "message": "The API successfully validated your access token."
}

```

### 🔓 Get admin message

```
$ http localhost:6060/api/messages/admin    
HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 62
content-type: application/json; charset=utf-8
date: Thu, 14 Oct 2021 11:50:00 GMT
server: Cowboy
x-request-id: Fq3jVpMEvnkYT4QAAAQs

{
    "message": "The API successfully recognized you as an admin."
}
```
