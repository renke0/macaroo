#!/usr/bin/env bash
source "$MACAROO_HOME/dotfiles/functions"
source "$MACAROO_HOME/dotfiles/ansi"
source "$MACAROO_HOME/helper.sh"

verify() {
  local tool="$1"

  toolname "$tool"
  if sdk current "$tool" 2>&1 | grep -q "Not using any version of $tool"; then
   sdk install "$tool"
  fi
  markdone
}

# Install SDKMAN! if not yet installed
msg "Configuring SDKMAN!"
toolname "sdkman!"
if [ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  curl -s "https://get.sdkman.io" | bash
fi
markdone

# Load SDKMAN!
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Symlink custom config for SDKMAN!
backup "$HOME/.sdkman/etc/config"
symlink "$MACAROO_HOME/sdkman.properties" "$HOME/.sdkman/etc/config"

# Install common SDKs
verify java
verify groovy
verify gradle

divider
