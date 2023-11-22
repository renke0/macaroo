#!/usr/bin/env bash

git_workspace_dir="$HOME/workspace"
git_main_ssh_config_file="$HOME/.ssh/config"
git_profiles_file="$HOME/.gitprofiles"
git_ssh_config_file="$HOME/.git_ssh_config"

configure_git() {
  if [ "$SKIP_GIT" == "true" ]; then
    msg "Skipping git config"
    return
  fi
  source "$MACAROO_HOME/dotfiles/functions"
  source "$MACAROO_SCRIPTS/commons.sh"

  msg "Configuring git"
  _init_git

  declare -A signing_keys
  for user in $(jq -rc ".github.users[]" <<< "$USER_CONFIGURATION_JSON"); do
    local username email gpg_passphrase ssh_passphrase
    username=$(jq -rc ".username" <<< "$user")
    email=$(jq -rc ".email" <<< "$user")
    gpg_passphrase=$(jq -rc ".gpgPassphrase" <<< "$user")
    ssh_passphrase=$(jq -rc ".sshPassphrase" <<< "$user")

    msg "Configuring $username"
    _generate_ssh_key "$username" "$email" "$ssh_passphrase"
    signing_keys["$username"]=$(_generate_gpg_key "$username" "$email" "$gpg_passphrase")

    _github_login "$username"
    _add_ssh_key_to_github "$username"
    _add_gpg_key_to_github "$username" "${signing_keys[$username]}"
    _github_logout
  done

  for profile in $(jq -rc ".github.profiles[]" <<< "$USER_CONFIGURATION_JSON"); do
    local profile_name username
    profile_name=$(jq -rc ".name" <<< "$profile")
    username=$(jq -rc ".user.username" <<< "$profile")
    email=$(jq -rc ".user.email" <<< "$profile")
    signing_key=${signing_keys[$username]}

    _add_git_profile "$profile_name" "$username" "$email" "$signing_key"
  done

  _create_git_ssh_file
  msg "Done."
}

_init_git() {
  [ ! -d "$git_workspace_dir" ] && mkdir -p "$git_workspace_dir"
  rm -f "$git_profiles_file"
  touch "$git_profiles_file"
  _init_ssh
  _init_gpg
}

_init_ssh() {
  eval "$(ssh-agent -s)" > /dev/null

  [ ! -d "$HOME/.ssh" ] && mkdir -p "$HOME/.ssh"
  [ ! -f "$git_main_ssh_config_file" ] && touch "$git_main_ssh_config_file"
  [ ! -f "$git_ssh_config_file" ] && touch "$git_ssh_config_file"
  chmod 600 "$git_main_ssh_config_file"
}

_init_gpg() {
  GPG_TTY=$(tty)
  export GPG_TTY

  rm -rf "$MACAROO_TEMP/gpg"
  mkdir -p "$MACAROO_TEMP/gpg"
}

_generate_ssh_key() {
  local username=$1
  local email=$2
  local passphrase=$3

  msg "Creating SSH key"
  local ssh_key_file="$HOME/.ssh/id_$username"
  ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_file" -N "$passphrase"
}

_create_git_ssh_file() {
  local statement="Include $git_ssh_config_file"
  if ! grep -qF "$statement" "$git_main_ssh_config_file"; then
    echo -e "$statement\n" | cat - "$git_ssh_config_file" > /tmp/out && mv /tmp/out "$git_ssh_config_file"
  fi

  local github_data
  github_data=$(jq -rc ".github" <<< "$USER_CONFIGURATION_JSON")
  ts-node "$MACAROO_TS" "hostfile" "$github_data" "$git_ssh_config_file"
}

_generate_gpg_key() {
  local username=$1
  local email=$2
  local passphrase=$3

  msg "Creating GPG key"
  gpg --passphrase "$passphrase" --pinentry-mode loopback --batch --gen-key << EOF > /dev/null
Key-Type: 1
Key-Length: 2048
Subkey-Type: 1
Subkey-Length: 2048
Name-Real: $username
Name-Email: $email
Expire-Date: 0
EOF

  # Extract the key id
  local signing_key
  signing_key=$(gpg --list-keys --keyid-format=long "$email" | gawk 'match($0, /^pub.+rsa2048\/([A-Z|0-9]+)/, a) {print a[1]}')

  # Export the gpg file
  gpg --armor --output "$MACAROO_TEMP/gpg/$signing_key.gpg" --export "$email"

  echo "$signing_key"
}

_add_git_profile() {
  local profile=$1
  local username=$2
  local email=$3
  local signing_key=$4

  msg "Creating profile $profile"
  workspace="$git_workspace_dir/$profile"
  [ ! -d "$workspace" ] && mkdir -p "$workspace"

  cat << EOF >> "$git_profiles_file"
[includeIf "gitdir:~/workspace/$profile"]
    path = ~/.git-$profile
EOF

  # Create the specific profile config
  local profile_config_file="$HOME/.git-$profile"
  rm -f "$profile_config_file"
  touch "$profile_config_file"
  cat << EOF >> "$profile_config_file"
[user]
  name = $username
  email = $email
  signingkey = $signing_key
EOF
}

_github_login() {
  local username=$1
  println "! Login with your $username github account and authorize the access"
  gh auth login --web --git-protocol https --scopes admin:public_key,write:gpg_key > /dev/tty 2>&1
}

_github_logout() {
  gh auth logout > /dev/tty 2>&1
}

_add_ssh_key_to_github() {
  local username=$1
  gh ssh-key add "$HOME/.ssh/id_$username.pub" --title "$username (set by macaroo)" --type authentication > /dev/tty 2>&1
}

_add_gpg_key_to_github() {
  local username=$1
  local signing_key=$2
  gh gpg-key add "$MACAROO_TEMP/gpg/$signing_key.gpg" --title "$username (set by macaroo)" > /dev/tty 2>&1
}
