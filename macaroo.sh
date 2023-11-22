#!/usr/bin/env bash

tmp_download="$TMPDIR/macaroo"
macaroo_home="$HOME/.macaroo/"

if [ -d "$macaroo_home" ]; then
  read -rp "Apparently macaroo is already installed. Do you want to remove it? (yes/no): " answer
  case "$answer" in
    [Yy] | [Yy][Ee][Ss]) rm -rf "$macaroo_home" ;;
    *) exit 1 ;;
  esac
fi

rm -rf "$tmp_download"
mkdir "$tmp_download"
curl -sL https://github.com/renke0/macaroo/archive/refs/heads/main.tar.gz | tar -xz -C "$tmp_download"
mv "$tmp_download/macaroo-main" "$macaroo_home"
cd "$macaroo_home" || exit
source "${macaroo_home}/scripts/bootstrap.sh"
