#!/bin/bash
# Qoder Autopilot v9.4 — Uninstall Script
# Usage: bash uninstall.sh

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${CYAN}Qoder Autopilot v9.4 — Uninstalling...${NC}"
echo ""

# ─── Remove skill (primary + symlink) ───
echo -e "  Removing symlink ~/.qoderwork/skills/qoder-autopilot"
rm -f "$HOME/.qoderwork/skills/qoder-autopilot"

echo -e "  Removing ~/.agents/skills/qoder-autopilot/"
rm -rf "$HOME/.agents/skills/qoder-autopilot"

# ─── Remove agents from both directories ───
echo -e "  Removing agent files from ~/.qoder/agents/"
rm -f "$HOME/.qoder/agents"/engineering-autopilot-*.md

echo -e "  Removing agent files from ~/.qoderwork/agents/"
rm -f "$HOME/.qoderwork/agents"/engineering-autopilot-*.md

# ─── Clean up old locations from previous versions (v9.1 and earlier) ───
if [ -d "$HOME/.qoder/skills/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Cleaning old: ~/.qoder/skills/qoder-autopilot/${NC}"
  rm -rf "$HOME/.qoder/skills/qoder-autopilot"
fi

# In case ~/.qoderwork/skills/qoder-autopilot was a real directory (not symlink) from older version
if [ -d "$HOME/.qoderwork/skills/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Cleaning old directory: ~/.qoderwork/skills/qoder-autopilot/${NC}"
  rm -rf "$HOME/.qoderwork/skills/qoder-autopilot"
fi

echo ""
echo -e "${GREEN}Uninstall complete. All skill and agent files removed.${NC}"
