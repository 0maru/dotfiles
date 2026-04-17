#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/preset.sh
source "$(dirname "$0")/preset.sh"

if command -v brew >/dev/null 2>&1; then
  echo -e "\033[32mHomebrew already installed\033[m"
else
  echo -e "\033[32mInstalling Homebrew\033[m"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v brew >/dev/null 2>&1; then
  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "brew command not found after installation" >&2
  exit 1
fi

brew bundle --file "$REPO_DIR/config/homebrew/Brewfile" --no-lock
