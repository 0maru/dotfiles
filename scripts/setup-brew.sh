#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/preset.sh
source "$(dirname "$0")/preset.sh"

/bin/bash "$REPO_DIR/install.sh" --command-line-tools-only

load_homebrew_path() {
  if ! command -v brew >/dev/null 2>&1; then
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      if [ -x "$brew_bin" ]; then
        brew_env="$("$brew_bin" shellenv)"
        eval "$brew_env"
        break
      fi
    done
  fi
}

# 新しいシェルで PATH が未設定でも、導入済みの Homebrew を先に見つける。
load_homebrew_path

if command -v brew >/dev/null 2>&1; then
  echo -e "\033[32mHomebrew already installed\033[m"
else
  echo -e "\033[32mInstalling Homebrew\033[m"
  brew_installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  /bin/bash -c "$brew_installer"
fi

load_homebrew_path

if ! command -v brew >/dev/null 2>&1; then
  echo "brew command not found after installation" >&2
  exit 1
fi

brew bundle --file "$REPO_DIR/config/homebrew/Brewfile"
