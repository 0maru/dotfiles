#!/usr/bin/env bash

source "$(dirname "$0")/preset.sh"

# Install Nix (Determinate Systems installer)
if ! command -v nix &>/dev/null; then
  echo -e "\033[32mInstalling Nix...\033[m"
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix | sh -s -- install
  # Source nix-daemon for current shell session
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
else
  echo -e "\033[32mNix is already installed\033[m"
fi

# Apply home-manager configuration
echo -e "\033[32mApplying home-manager configuration...\033[m"
nix run home-manager -- switch --flake "$REPO_DIR"
