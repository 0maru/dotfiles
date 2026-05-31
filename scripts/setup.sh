#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/preset.sh
source "$(dirname "$0")/preset.sh"

/bin/bash "$SCRIPTS_DIR/setup-nix.sh"
/bin/bash "$SCRIPTS_DIR/setup-brew.sh"
/bin/bash "$SCRIPTS_DIR/setup-link.sh"
