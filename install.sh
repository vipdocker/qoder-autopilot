#!/bin/bash
# Qoder Autopilot v9.5 — Install Script
# Usage: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/skill"
AGENT_SRC="$SCRIPT_DIR/agents"

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${CYAN}Qoder Autopilot v9.5 — Installing...${NC}"
echo ""

# ─── Pre-flight checks ───
if [ ! -f "$SKILL_SRC/SKILL.md" ]; then
  echo -e "${RED}Error: skill/SKILL.md not found. Run this script from the package directory.${NC}"
  exit 1
fi

AGENT_COUNT=$(ls "$AGENT_SRC"/engineering-autopilot-*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$AGENT_COUNT" -ne 7 ]; then
  echo -e "${RED}Error: Expected 7 agent files, found $AGENT_COUNT.${NC}"
  exit 1
fi

PHASE_COUNT=$(ls "$SKILL_SRC"/phases/phase-*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$PHASE_COUNT" -ne 8 ]; then
  echo -e "${RED}Error: Expected 8 phase files, found $PHASE_COUNT.${NC}"
  exit 1
fi

ERRORS=0

# ─── Cleanup old locations from previous versions ───
echo -e "${CYAN}[Cleanup: previous versions]${NC}"

# v9.1 and earlier: skill was in ~/.qoder/skills/
if [ -d "$HOME/.qoder/skills/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Removing old: ~/.qoder/skills/qoder-autopilot/ (pre-v9.2)${NC}"
  rm -rf "$HOME/.qoder/skills/qoder-autopilot"
fi

# Remove old validator agent (v6.x → v7.0+ upgrade)
for dir in "$HOME/.qoder/agents" "$HOME/.qoderwork/agents"; do
  if [ -f "$dir/engineering-autopilot-validator.md" ]; then
    echo -e "  ${YELLOW}Removing deprecated validator agent from $dir${NC}"
    rm -f "$dir/engineering-autopilot-validator.md"
  fi
done

# Remove stale symlink if exists
if [ -L "$HOME/.qoderwork/skills/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Removing existing symlink ~/.qoderwork/skills/qoder-autopilot${NC}"
  rm -f "$HOME/.qoderwork/skills/qoder-autopilot"
elif [ -d "$HOME/.qoderwork/skills/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Removing existing directory ~/.qoderwork/skills/qoder-autopilot (will be replaced by symlink)${NC}"
  rm -rf "$HOME/.qoderwork/skills/qoder-autopilot"
fi

echo ""

# ─── Install Skill files to ~/.agents/skills/qoder-autopilot/ ───
SKILL_DIR="$HOME/.agents/skills/qoder-autopilot"

echo -e "${CYAN}[Skill → ~/.agents/skills/qoder-autopilot/]${NC}"

mkdir -p "$SKILL_DIR/phases"
cp "$SKILL_SRC/SKILL.md" "$SKILL_DIR/"
cp "$SKILL_SRC/reference.md" "$SKILL_DIR/"
cp "$SKILL_SRC/self-check-protocol.md" "$SKILL_DIR/"
cp "$SKILL_SRC"/phases/phase-*.md "$SKILL_DIR/phases/"

# Verify skill install
ROOT_COUNT=0
for f in SKILL.md reference.md self-check-protocol.md; do
  [ -f "$SKILL_DIR/$f" ] && ROOT_COUNT=$((ROOT_COUNT + 1))
done
INSTALLED_PHASES=$(ls "$SKILL_DIR"/phases/phase-*.md 2>/dev/null | wc -l | tr -d ' ')
TOTAL_SKILL=$((ROOT_COUNT + INSTALLED_PHASES))

if [ "$TOTAL_SKILL" -eq 11 ]; then
  echo -e "  Skill files: ${GREEN}$TOTAL_SKILL/11${NC} ($ROOT_COUNT root + $INSTALLED_PHASES phases)"
else
  echo -e "  Skill files: ${RED}$TOTAL_SKILL/11${NC}"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ─── Create symlink: ~/.qoderwork/skills/qoder-autopilot → ~/.agents/skills/qoder-autopilot ───
echo -e "${CYAN}[Symlink → ~/.qoderwork/skills/qoder-autopilot]${NC}"

mkdir -p "$HOME/.qoderwork/skills"
ln -s "$HOME/.agents/skills/qoder-autopilot" "$HOME/.qoderwork/skills/qoder-autopilot"

if [ -L "$HOME/.qoderwork/skills/qoder-autopilot" ]; then
  echo -e "  Symlink: ${GREEN}OK${NC} → ~/.agents/skills/qoder-autopilot"
else
  echo -e "  Symlink: ${RED}FAILED${NC}"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ─── Install Agent files to ~/.qoder/agents/ AND ~/.qoderwork/agents/ ───
echo -e "${CYAN}[Agents → ~/.qoder/agents/ + ~/.qoderwork/agents/]${NC}"

mkdir -p "$HOME/.qoder/agents"
mkdir -p "$HOME/.qoderwork/agents"
cp "$AGENT_SRC"/engineering-autopilot-*.md "$HOME/.qoder/agents/"
cp "$AGENT_SRC"/engineering-autopilot-*.md "$HOME/.qoderwork/agents/"

# Verify agents
AGENTS_QODER=$(ls "$HOME/.qoder/agents"/engineering-autopilot-*.md 2>/dev/null | wc -l | tr -d ' ')
AGENTS_QODERWORK=$(ls "$HOME/.qoderwork/agents"/engineering-autopilot-*.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$AGENTS_QODER" -eq 7 ] && [ "$AGENTS_QODERWORK" -eq 7 ]; then
  echo -e "  ~/.qoder/agents/:     ${GREEN}$AGENTS_QODER/7${NC}"
  echo -e "  ~/.qoderwork/agents/: ${GREEN}$AGENTS_QODERWORK/7${NC}"
else
  echo -e "  ~/.qoder/agents/:     ${RED}$AGENTS_QODER/7${NC}"
  echo -e "  ~/.qoderwork/agents/: ${RED}$AGENTS_QODERWORK/7${NC}"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ─── Summary ───
if [ "$ERRORS" -eq 0 ]; then
  echo -e "${GREEN}Installation complete.${NC}"
  echo ""
  echo "  Skill (primary):  ~/.agents/skills/qoder-autopilot/     (11 files)"
  echo "  Skill (symlink):  ~/.qoderwork/skills/qoder-autopilot → primary"
  echo "  Agents:           ~/.qoder/agents/                      (7 files)"
  echo "  Agents (mirror):  ~/.qoderwork/agents/                  (7 files)"
  echo ""
  echo "Trigger: qoder-autopilot / 自动开发 / 全自动 / autopilot / 端到端开发"
  echo ""
  echo -e "${CYAN}v9.5 changes from v9.4:${NC}"
  echo "  - /cso: Security audit (OWASP+STRIDE) in reviewer Phase 4B — security_audit quality gate, CRITICAL = BLOCKING"
  echo "  - /benchmark: Performance baseline (Core Web Vitals) in finisher Phase 5A — perf_baseline field, IF frontend"
  echo "  - /investigate: Systematic debugging (Iron Law, 3-cycle) in implementer Phase 4A — on self-verify FAIL"
  echo "  - /health: Code quality score (5 dimensions + trend) in Phase 7 EVOLVE main session"
  echo "  - Mandatory skills: 8 → 12 (+ cso, benchmark, investigate, health from gstack)"
  echo "  - FAILURE MODES: 14 → 16 (+ 安全漏洞漏审, + 性能退化静默交付)"
  echo "  - Global Rules: 14 → 18"
  echo "  - Phase 6 audit checklist: 8 rows → 12 rows"
  echo "  - Batch Gate: + security_audit PASS"
  echo "  - Finish Gate: + perf_baseline PASS (if frontend)"
else
  echo -e "${RED}Installation finished with errors. Check output above.${NC}"
  exit 1
fi
