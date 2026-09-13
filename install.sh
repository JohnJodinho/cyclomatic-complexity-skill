#!/usr/bin/env bash
# Installs cyclomatic-complexity as a global Antigravity skill on Linux / macOS.
# Usage: curl -fsSL https://raw.githubusercontent.com/JohnJodinho/cyclomatic-complexity-skill/master/install.sh | bash

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/JohnJodinho/cyclomatic-complexity-skill.git}"
GLOBAL_SKILLS_DIR="${HOME}/.gemini/config/skills"
TARGET_DIR="${GLOBAL_SKILLS_DIR}/cyclomatic-complexity"

echo "==> Antigravity Skill Installer: cyclomatic-complexity"

mkdir -p "${GLOBAL_SKILLS_DIR}"

if [[ -d "${TARGET_DIR}" ]]; then
    if [[ -d "${TARGET_DIR}/.git" ]]; then
        echo "Existing git installation detected. Updating via git pull..."
        git -C "${TARGET_DIR}" pull --ff-only
        echo "[SUCCESS] Updated cyclomatic-complexity skill!"
        exit 0
    else
        echo "Directory ${TARGET_DIR} already exists (not a git repo). Removing and reinstalling..."
        rm -rf "${TARGET_DIR}"
    fi
fi

echo "Cloning ${REPO_URL} into ${TARGET_DIR}..."
git clone "${REPO_URL}" "${TARGET_DIR}"

echo ""
echo "[SUCCESS] cyclomatic-complexity skill installed globally for Antigravity!"
echo "Location: ${TARGET_DIR}"
echo "Antigravity agents will now automatically discover this skill across all your workspaces."
