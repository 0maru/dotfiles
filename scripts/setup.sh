#!/usr/bin/env bash

source "$(dirname "$0")/preset.sh"

/bin/bash "$SCRIPTS_DIR/setup-nix.sh"
/bin/bash "$SCRIPTS_DIR/setup-brew.sh"
/bin/bash "$SCRIPTS_DIR/setup-link.sh"
/bin/bash "$SCRIPTS_DIR/install-code-extensions.sh"
