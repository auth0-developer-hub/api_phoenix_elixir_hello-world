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

```

| Variable           | Default                 | Description                                     |
| ------------------ | ----------------------- | ----------------------------------------------- |
|  PORT              | 6060                    | Port the application accepts requests           |
|  CLIENT_ORIGIN_URL | http://localhost:4040   | Origin from which API accepts requests          |
|  SECRET_KEY_BASE   |                         | used to sign/encrypt cookies and other secrets. |

You can generate `SECRET_KEY_BASE` by executing the following command as [recommended by the Phoenix framework](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Secret.html):
 `mix phx.gen.secret`

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

### Get public message as an anonymous user

Request:
```bash
curl localhost:6060/api/messages/public -i
```

Response:

Status: 200

```bash
{
  "message": "The API doesn't require an access token to share this message."
}
```

### Get protected message as an anonymous user
Request:

```bash
curl localhost:6060/api/messages/protected -i
```

Response:

Status code: 200

```bash
{
  "message": "The API successfully validated your access token."
}
```

### Get admin message as an anonymous user

Request:

```bash
curl localhost:6060/api/messages/admin -i
```

Response:

Status code: 200

```bash
{
  "message": "The API successfully recognized you as an admin."
}
```


### Request an invalid resource

Test that your 404 exception handling is working as expected:

Request:

```bash
curl localhost:6060/api/messages/invalid -i
```

Response:

Status code: 404

```bash
{
  "message": "Not Found"
}
```
