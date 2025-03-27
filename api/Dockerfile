FROM elixir:latest

RUN apt-get update && \
    apt-get -y install sudo

ADD . /app

RUN mix local.hex --force && \
    mix local.rebar --force
RUN mix archive.install hex phx_new 1.4.0-dev.0

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

WORKDIR /app

RUN mix deps.get

RUN mix compile

EXPOSE 4000

CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && mix phx.server"]