#!/usr/bin/env bash

configure_docker() {
  if [ "$SKIP_DOCKER" == "true" ]; then
    msg "Skipping docker config"
    return
  fi
  source "$MACAROO_SCRIPTS/commons.sh"

  msg "Configuring docker"
  msg "Creating resources"
  mkdir -p "$HOME/.docker/cli-plugins"

  msg "Creating references"
  ln -sfn "$(brew --prefix)"/opt/docker-compose/bin/docker-compose "$HOME/.docker/cli-plugins/docker-compose"
  ln -sfn "$(brew --prefix)"/opt/docker-buildx/bin/docker-buildx "$HOME/.docker/cli-plugins/docker-buildx"

  msg "Done."
}
