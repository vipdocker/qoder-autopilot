#!/bin/bash
# Qoder Autopilot v9.6 — Install Script
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

echo -e "${CYAN}Qoder Autopilot v9.6 — Installing...${NC}"
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
if [ "$PHASE_COUNT" -ne 9 ]; then
  echo -e "${RED}Error: Expected 9 phase files (v9.6: includes phase-3b-ac-negotiation.md), found $PHASE_COUNT.${NC}"
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

if [ "$TOTAL_SKILL" -eq 12 ]; then
  echo -e "  Skill files: ${GREEN}$TOTAL_SKILL/12${NC} ($ROOT_COUNT root + $INSTALLED_PHASES phases)"
else
  echo -e "  Skill files: ${RED}$TOTAL_SKILL/12${NC}"
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
  echo "  Skill (primary):  ~/.agents/skills/qoder-autopilot/     (12 files)"
  echo "  Skill (symlink):  ~/.qoderwork/skills/qoder-autopilot → primary"
  echo "  Agents:           ~/.qoder/agents/                      (7 files)"
  echo "  Agents (mirror):  ~/.qoderwork/agents/                  (7 files)"
  echo ""
  echo "Trigger: qoder-autopilot / 自动开发 / 全自动 / autopilot / 端到端开发"
  echo ""
  echo -e "${CYAN}v9.6 changes from v9.5 (Anthropic harness-design alignment):${NC}"
  echo "  - Phase 3B AC negotiation: reviewer fast-mode evaluates every AC (CLEAR/AMBIGUOUS/UNCOVERED/CONTRADICTORY); planner §2e single corrective replan"
  echo "  - Phase 4A.5 task-level micro-loop: conditional on T_contract_* or touches_field_mapping_boundary; reviewer THIN MODE; max 2 refine cycles"
  echo "  - Field Mapping split: designer §2c ≤12-line direction declaration → implementer §1e grep-anchored Evidence Table → reviewer diff (generation/evaluation separation)"
  echo "  - Per-Skill Sub-Artifact protocol: reviewer writes evidence to review_artifact_dir/batch-N-*.md; main report stays compact"
  echo "  - Calibration Anchors: every 0-10 self-rating dimension carries 2/5/8 examples; score 10 reserved (anti-leniency drift)"
  echo "  - Layer ROI table (14 layers × 3-run rolling window) + Ablation Run protocol (only admissible evidence for layer removal)"
  echo "  - Harness Assumption Snapshot in retro (model/env drift detection)"
  echo "  - Phase 6 Checklist E (9 rows: AC review / corrective replan / DAG tagging / micro-loop coverage / Evidence Tables / sub-artifacts / ROI / snapshot / ablation)"
  echo "  - Implementer §1g Corrective-Findings Loop Handler (re-dispatch from micro-loop)"
  echo "  - Mandatory skills: 12 → 13 (frontend-design now an explicit row; rest unchanged)"
  echo "  - FAILURE MODES: 16 → 21 (+18 AC ambiguity, +19 cross-layer batch cascade, +20 design over-spec cascade, +21 no data for layer removal)"
  echo "  - Global Rules: 18 → 22 (+20 calibration anchor citation, +21 sub-artifact discipline, +22 ablation safety)"
  echo "  - Typical dispatches: 6-9 → 7-11 (3B always; 4A.5 only when triggered)"
else
  echo -e "${RED}Installation finished with errors. Check output above.${NC}"
  exit 1
fi
