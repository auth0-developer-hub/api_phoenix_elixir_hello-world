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
export PORT=6060
export CLIENT_ORIGIN_URL=http://localhost:4040
export SECRET_KEY_BASE=your_secret_key
export AUTH0_DOMAIN=auth0_domain
export AUTH0_AUDIENCE=auth0_audience

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

### Register an Elixir/Phoenix API with Auth0

- Open the [APIs](https://manage.auth0.com/#/apis) section of the Auth0 Dashboard.

- Click on the **Create API** button.

- Provide a **Name** value such as _Hello World API Server_.

- Set its **Identifier** to `https://api.example.com` or any other value of your liking.

- Leave the signing algorithm as `RS256` as it's the best option from a security standpoint.

- Click on the **Create** button.

> View ["Register APIs" document](https://auth0.com/docs/get-started/set-up-apis) for more details.

### Connect Elixir/Phoenix API with Auth0

Get the values for `AUTH0_AUDIENCE` and `AUTH0_DOMAIN` in `.env` from your Auth0 API in the Dashboard.

Head back to your Auth0 API page, and **follow these steps to get the Auth0 Audience**:

![Get the Auth0 Audience to configure an API](https://cdn.auth0.com/blog/complete-guide-to-user-authentication/get-the-auth0-audience.png)

1. Click on the **"Settings"** tab.

2. Locate the **"Identifier"** field and copy its value.

3. Paste the "Identifier" value as the value of `AUTH0_AUDIENCE` in `.env`.

Now, **follow these steps to get the Auth0 Domain value**:

![Get the Auth0 Domain to configure an API](https://cdn.auth0.com/blog/complete-guide-to-user-authentication/get-the-auth0-domain.png)

1. Click on the **"Test"** tab.
2. Locate the section called **"Asking Auth0 for tokens from my application"**.
3. Click on the **cURL** tab to show a mock `POST` request.
4. Copy your Auth0 domain, which is _part_ of the `--url` parameter value: `tenant-name.region.auth0.com`.
5. Paste the Auth0 domain value as the value of `AUTH0_DOMAIN` in `.env`.

**Tips to get the Auth0 Domain**

- The Auth0 Domain is the substring between the protocol, `https://` and the path `/oauth/token`.

- The Auth0 Domain follows this pattern: `tenant-name.region.auth0.com`.

- The `region` subdomain (`au`, `us`, or `eu`) is optional. Some Auth0 Domains don't have it.

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

### As an anonymous user:
Request:

```bash
curl localhost:6060/api/messages/public
```

Response:

Status code: 200

```bash
{
  "message": "The API doesn't require an access token to share this message."
}
```

Request:

```bash
curl localhost:6060/api/messages/protected
```

Response:

Status code: 401

```bash
{
  "message": "Requires authentication"
}
```

Request:

```bash
curl localhost:6060/api/messages/admin
```

Response:

Status code: 401

```bash
{
  "message": "Requires authentication"
}
```

Request:

```bash
curl localhost:6060/api/messages/invalid
```

Response:

Status code: 404

```bash
{
  "message": "Not Found"
}
```

### As an authenticated user or with a valid test access token:
Make a secure request to your API server by including an access token in the authorization header:

Request:

```bash
curl --request GET \
  --url http:/localhost:6060/api/messages/public \
  --header 'authorization: Bearer AUTH0-ACCESS-TOKEN'
```

Response:

Status code: 200

```bash
{
  "message": "The API doesn't require an access token to share this message."
}
```

Request:

```bash
curl --request GET \
  --url http:/localhost:6060/api/messages/protected \
  --header 'authorization: Bearer AUTH0-ACCESS-TOKEN'
```

Response:

Status code: 200

```bash
{
  "message": "The API successfully validated your access token."
}
```

Request:

```bash
curl --request GET \
  --url http:/localhost:6060/api/messages/admin \
  --header 'authorization: Bearer AUTH0-ACCESS-TOKEN'
```

Response:

Status code: 200

```
{
  "message": "The API successfully recognized you as an admin."
}
```

Request:

```bash
curl --request GET \
  --url http:/localhost:6060/api/messages/invalid \
  --header 'authorization: Bearer AUTH0-ACCESS-TOKEN'
```

Response:

Status code: 404

```bash
{
  "message": "Not Found"
}
```

When using an invalid test access token:
Request:

```bash
curl --request GET \
  --url http:/localhost:6060/api/messages/protected \
  --header 'authorization: Bearer invalidtoken1234567890'
```

Response:

Status code: 401

```bash
{
  "message": "Bad credentials"
}
```
