FROM ubuntu:18.04

WORKDIR /app

RUN \
  apt update \
  && apt -y install curl gnupg

RUN \
  curl -sSL https://dist.crystal-lang.org/apt/setup.sh | bash \
  && apt -y install crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev

COPY . /app

RUN \
  crystal build --release -o bin/amqproxy src/amqproxy.cr

CMD ["/app/bin/run"]
