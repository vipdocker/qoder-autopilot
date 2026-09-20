#!/bin/bash
# Qoder Autopilot v9.7.2 — Uninstall Script
# Usage: bash uninstall.sh

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${CYAN}Qoder Autopilot v9.7.2 — Uninstalling...${NC}"
echo ""

# ─── Remove skill (current layout: ~/.agents/skills/ only) ───
echo -e "  Removing ~/.agents/skills/qoder-autopilot/"
rm -rf "$HOME/.agents/skills/qoder-autopilot"

# ─── Remove agents (current layout: ~/.qoder/agents/qoder-autopilot/) ───
echo -e "  Removing ~/.qoder/agents/qoder-autopilot/"
rm -rf "$HOME/.qoder/agents/qoder-autopilot"

# ─── Clean up old locations from previous versions ───
if ls "$HOME/.qoder/agents"/engineering-autopilot-*.md >/dev/null 2>&1; then
  echo -e "  ${YELLOW}Cleaning old: ~/.qoder/agents/engineering-autopilot-*.md (root-level, old layout)${NC}"
  rm -f "$HOME/.qoder/agents"/engineering-autopilot-*.md
fi

if ls "$HOME/.qoderwork/agents"/engineering-autopilot-*.md >/dev/null 2>&1; then
  echo -e "  ${YELLOW}Cleaning old: ~/.qoderwork/agents/engineering-autopilot-*.md (legacy mirror)${NC}"
  rm -f "$HOME/.qoderwork/agents"/engineering-autopilot-*.md
fi

if [ -d "$HOME/.qoderwork/agents/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Cleaning old: ~/.qoderwork/agents/qoder-autopilot/ (legacy mirror)${NC}"
  rm -rf "$HOME/.qoderwork/agents/qoder-autopilot"
fi

# Legacy skill locations (v9.1 and earlier / pre-unification symlink)
if [ -d "$HOME/.qoder/skills/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Cleaning old: ~/.qoder/skills/qoder-autopilot/${NC}"
  rm -rf "$HOME/.qoder/skills/qoder-autopilot"
fi

if [ -e "$HOME/.qoderwork/skills/qoder-autopilot" ] || [ -L "$HOME/.qoderwork/skills/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Cleaning old: ~/.qoderwork/skills/qoder-autopilot (symlink or directory)${NC}"
  rm -rf "$HOME/.qoderwork/skills/qoder-autopilot"
fi

echo ""
echo -e "${GREEN}Uninstall complete. All skill and agent files removed.${NC}"
