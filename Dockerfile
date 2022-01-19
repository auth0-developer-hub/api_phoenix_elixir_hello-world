FROM hexpm/elixir:1.13.2-erlang-24.1.2-debian-buster-20210902-slim@sha256:72c8db81d302cc82d4a3b9fc63a959742aef1437b59d89b512918b973b3cc1dd AS build
RUN groupadd auth0 && useradd -m developer -g auth0
RUN mkdir app && chown -R developer:auth0 /app
WORKDIR /app
USER developer
RUN mix local.hex --force && \
    mix local.rebar --force
ENV MIX_ENV=prod
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
COPY config/config.exs config/$MIX_ENV.exs config/
RUN mix deps.compile
COPY lib lib
RUN mix compile
COPY config/runtime.exs config/
RUN mix release

FROM debian:buster-slim@sha256:b7d8b4fc7754e9bd3cc19e65c64fe88a17e0fde012308a741ddc8e20b291ae2e
RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*
RUN groupadd auth0 && useradd -m developer -g auth0
USER developer
WORKDIR /app
COPY --from=build --chown=developer:auth0 /app/_build/prod/rel/hello_world ./
ENTRYPOINT ["bin/hello_world", "start"]
