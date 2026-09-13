#!/usr/bin/env bash
# Uninstalls the global cyclomatic-complexity Antigravity skill on Linux / macOS.

set -euo pipefail

TARGET_DIR="${HOME}/.gemini/config/skills/cyclomatic-complexity"

if [[ -d "${TARGET_DIR}" ]]; then
    rm -rf "${TARGET_DIR}"
    echo "[SUCCESS] Removed cyclomatic-complexity from ${TARGET_DIR}"
else
    echo "Skill not found at ${TARGET_DIR}"
fi
