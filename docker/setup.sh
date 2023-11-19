#!/usr/bin/env bash

# create setup folder to hold docker plugins
mkdir -p "$HOME/.docker/cli-plugins"

# symlinking docker compose and buildx to work as setup docker plugins
ln -sfn "$(brew --prefix)"/opt/docker-compose/bin/docker-compose "$HOME/.docker/cli-plugins/docker-compose"
ln -sfn "$(brew --prefix)"/opt/docker-buildx/bin/docker-buildx "$HOME/.docker/cli-plugins/docker-buildx"
