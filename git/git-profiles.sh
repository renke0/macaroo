#!/usr/bin/env bash

source "$HOME/.mac-config/functions.sh"

workspace_dir="$HOME/workspace"
ssh_config_file="$HOME/.ssh/config"
profiles_file="$HOME/.gitprofiles"

generate_ssh_key() {
  local profile=$1
  local email=$2
  local passphrase=$3

  # Create ssh file
  local ssh_key_file="$HOME/.ssh/id_$profile"
  ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_file" -N "$passphrase" > /dev/null

  # Resolve host
  local host="github.com"
  if grep -q "Host github.com" "$ssh_config_file"; then
    host="$profile.$host"
  fi

  # Add info to the ssh config file
  cat <<EOF >>"$ssh_config_file"
Host $host
  HostName github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_$profile

EOF
}

generate_gpg_key() {
  local username=$1
  local email=$2
  local passphrase=$3

  # Generate the gpg key
  gpg --passphrase "$passphrase" --pinentry-mode loopback --batch --gen-key <<EOF > /dev/null
Key-Type: 1
Key-Length: 2048
Subkey-Type: 1
Subkey-Length: 2048
Name-Real: $username
Name-Email: $email
Expire-Date: 0
EOF

  # Extract the key id
  local signingkey
  signingkey=$(gpg --list-keys --keyid-format=long "$email" | gawk 'match($0, /^pub.+rsa2048\/([A-Z|0-9]+)/, a) {print a[1]}')

  # Export the gpg file
  gpg --armor --output "temp/gpg/$signingkey".gpg --export "$email"

  echo "$signingkey"
}

add_git_profile() {
  local profile=$1
  local username=$2
  local email=$3
  local signingkey=$4

  cat <<EOF >> "$profiles_file"
[includeIf "gitdir:~/workspace/$profile"]
    path = ~/.git-$profile
EOF

    # Create the specific profile config
  local profile_config_file="$HOME/.git-$profile"
  touch "$profile_config_file"
  cat <<EOF >> "$profile_config_file"
[user]
  name = $username
  email = $email
  signingkey = $signingkey
EOF
}

echo "Configuring git profiles"

# Start the ssh-agent
eval "$(ssh-agent -s)" > /dev/null

# Set GPG input terminal
GPG_TTY=$(tty)
export GPG_TTY

# Check and create potentially missing files and directories
[ ! -d "$HOME/.ssh" ] && mkdir -p "$HOME/.ssh"
[ ! -d "temp/gpg" ] && mkdir -p "temp/gpg"
[ ! -f "$ssh_config_file" ] && touch "$ssh_config_file"
[ ! -f "$profiles_file" ] && touch "$profiles_file"

# Set ssh config permissions
chmod 600 "$ssh_config_file"

add_more_profiles="y"

while [[ "$add_more_profiles" == *([Yy]|[Yy][Ee][Ss]) ]]; do
  # Read profile info
  read -rp "Enter Git profile name: " profile_name
  read -rp "Enter the github username for $profile_name: " git_username
  read -rp "Enter the github email for $profile_name: " git_email
  read -srp "Enter a passphrase for the SSH key: " ssh_passphrase
  echo -e "\n"
  read -srp "Enter a passphrase for the GPG key: " gpg_passphrase
  echo -e "\n"

  generate_ssh_key "$profile_name" "$git_email" "$ssh_passphrase"

  signingkey=$(generate_gpg_key "$git_username" "$git_email" "$gpg_passphrase")

  add_git_profile "$profile_name" "$git_username" "$git_email" "$signingkey"

  workspace="$workspace_dir/$profile_name"
  [ ! -d "$workspace" ] && mkdir -p "$workspace"

  read -rp "Do you want to add more profiles? (y/n): " add_more_profiles
done

ssh-add --apple-use-keychain "$ssh_config_file"
