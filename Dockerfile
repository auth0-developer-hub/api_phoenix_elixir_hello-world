FROM hexpm/elixir:1.13.2-erlang-24.1.2-debian-buster-20210902-slim AS build
RUN groupadd auth0 && useradd -m developer -g auth0
RUN mkdir app && chown -R developer:auth0 /app
WORKDIR /app
USER developer

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set env to prod
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# copy compile configuration files
RUN mkdir config
COPY config/config.exs config/$MIX_ENV.exs config/

# compile dependencies
RUN mix deps.compile

# compile project
COPY lib lib
RUN mix compile

# copy runtime configuration file
COPY config/runtime.exs config/

# assemble release
RUN mix release

FROM hexpm/elixir:1.13.2-erlang-24.1.2-debian-buster-20210902-slim
RUN groupadd auth0 && useradd -m developer -g auth0
USER developer
WORKDIR /app
COPY --from=build --chown=developer:auth0 /app/_build/prod/rel/hello_world ./
ENTRYPOINT ["bin/hello_world", "start"]
