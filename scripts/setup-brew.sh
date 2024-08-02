#!/usr/bin/env bash

source "$(dirname "$0")/preset.sh"

if hash brew 2>/dev/null; then
  echo -e "\033[32mHomebrew already installed\033[m"
else
  echo -e "\033[32mInstalling Homebrew\033[m"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew bundle --file "$REPO_DIR/config/homebrew/Brewfile" --no-lock
