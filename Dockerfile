FROM ubuntu:24.04

ARG SIGNAL_CLI_VERSION=0.13.24

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        openjdk-21-jre-headless \
        python3 \
        && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL \
    "https://github.com/AsamK/signal-cli/releases/download/v${SIGNAL_CLI_VERSION}/signal-cli-${SIGNAL_CLI_VERSION}-Linux-native.tar.gz" \
    -o /tmp/signal-cli.tar.gz && \
    tar -xzf /tmp/signal-cli.tar.gz -C /opt && \
    rm /tmp/signal-cli.tar.gz && \
    ln -s "/opt/signal-cli" /usr/local/bin/signal-cli

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

RUN mkdir -p /root/.nanobot

WORKDIR /app
COPY . /app

RUN uv tool install .

# Gateway default port
EXPOSE 18790

ENTRYPOINT ["nanobot"]
CMD ["status"]
