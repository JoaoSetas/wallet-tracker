FROM elixir:1.15

WORKDIR /home/app

RUN mix local.hex --force

RUN mix archive.install hex phx_new 1.7.10 --force

RUN apt-get update

RUN apt-get install -y inotify-tools