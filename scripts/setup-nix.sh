#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/preset.sh
. "$(dirname "$0")/preset.sh"

TARGET_USER="${SUDO_USER:-$USER}"

# Install Nix (Determinate Systems installer)
if ! command -v nix >/dev/null 2>&1; then
  printf '\033[32mInstalling Nix...\033[m\n'
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix | sh -s -- install
  # Source nix-daemon for current shell session
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    # shellcheck source=/dev/null
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
else
  printf '\033[32mNix is already installed\033[m\n'
fi

# nix-darwin 経由で home-manager も適用する
printf '\033[32mApplying nix-darwin configuration...\033[m\n'
nix_bin="$(command -v nix)"
if [ "$(id -u)" -eq 0 ]; then
  "$nix_bin" --extra-experimental-features 'nix-command flakes' \
    run "$REPO_DIR#darwin-rebuild" -- switch --flake "$REPO_DIR#$TARGET_USER"
else
  sudo "$nix_bin" --extra-experimental-features 'nix-command flakes' \
    run "$REPO_DIR#darwin-rebuild" -- switch --flake "$REPO_DIR#$TARGET_USER"
fi
