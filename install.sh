#!/usr/bin/env bash
set -u

INSTALL_DIR="$HOME/workspaces/github.com/0maru/dotfiles"

if [ -d "$INSTALL_DIR" ]; then
  echo -e "\033[32mUpdating dotfiles...\033[m"
  git -C "$INSTALL_DIR" pull
else
  echo -e "\033[32mInstalling dotfiles...\033[m"
  git clone https://github.com/0maru/dotfiles "$INSTALL_DIR"
fi

/bin/bash "$INSTALL_DIR/scripts/setup.sh"
