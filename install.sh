#!/bin/bash
# Qoder Autopilot v9.7.2 — Install Script
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

echo -e "${CYAN}Qoder Autopilot v9.7.2 — Installing...${NC}"
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

# ─── Cross-file contract validation (v9.6.1) ───
# Phase files and agent files are a generator/consumer pair. Installing them
# out of sync reproduces FAILURE 11/14 inside the harness itself.
if [ -f "$SCRIPT_DIR/validate.sh" ]; then
  echo -e "${CYAN}[Contract validation]${NC}"
  if bash "$SCRIPT_DIR/validate.sh" --quiet; then
    echo -e "  Contracts: ${GREEN}PASS${NC}"
  else
    echo -e "${RED}Error: phase↔agent contract validation failed. Run 'bash validate.sh' for details.${NC}"
    echo -e "${RED}Refusing to install drifted files.${NC}"
    exit 1
  fi
  echo ""
else
  echo -e "${YELLOW}Warning: validate.sh not found — skipping contract validation.${NC}"
fi

ERRORS=0

# ─── Cleanup old locations from previous versions ───
echo -e "${CYAN}[Cleanup: previous versions]${NC}"

# v9.1 and earlier: skill was in ~/.qoder/skills/
if [ -d "$HOME/.qoder/skills/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Removing old: ~/.qoder/skills/qoder-autopilot/ (pre-v9.2)${NC}"
  rm -rf "$HOME/.qoder/skills/qoder-autopilot"
fi

# Skills now live ONLY in ~/.agents/skills/ — drop the legacy ~/.qoderwork symlink
if [ -e "$HOME/.qoderwork/skills/qoder-autopilot" ] || [ -L "$HOME/.qoderwork/skills/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Removing old: ~/.qoderwork/skills/qoder-autopilot (legacy symlink)${NC}"
  rm -rf "$HOME/.qoderwork/skills/qoder-autopilot"
fi

# Agents now live ONLY in ~/.qoder/agents/qoder-autopilot/ — remove root-level copies
if ls "$HOME/.qoder/agents"/engineering-autopilot-*.md >/dev/null 2>&1; then
  echo -e "  ${YELLOW}Removing old: ~/.qoder/agents/engineering-autopilot-*.md (root-level, old layout)${NC}"
  rm -f "$HOME/.qoder/agents"/engineering-autopilot-*.md
fi

# ~/.qoderwork is the pre-migration config dir and is no longer written — remove any mirror copy
if ls "$HOME/.qoderwork/agents"/engineering-autopilot-*.md >/dev/null 2>&1; then
  echo -e "  ${YELLOW}Removing old: ~/.qoderwork/agents/engineering-autopilot-*.md (legacy mirror)${NC}"
  rm -f "$HOME/.qoderwork/agents"/engineering-autopilot-*.md
fi
if [ -d "$HOME/.qoderwork/agents/qoder-autopilot" ]; then
  echo -e "  ${YELLOW}Removing old: ~/.qoderwork/agents/qoder-autopilot/ (legacy mirror)${NC}"
  rm -rf "$HOME/.qoderwork/agents/qoder-autopilot"
fi

# Remove old validator agent (v6.x → v7.0+ upgrade), root and subdir locations
for f in "$HOME/.qoder/agents/engineering-autopilot-validator.md" \
         "$HOME/.qoder/agents/qoder-autopilot/engineering-autopilot-validator.md" \
         "$HOME/.qoderwork/agents/engineering-autopilot-validator.md"; do
  if [ -f "$f" ]; then
    echo -e "  ${YELLOW}Removing deprecated validator agent: $f${NC}"
    rm -f "$f"
  fi
done

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

# ─── Install Agent files to ~/.qoder/agents/qoder-autopilot/ ───
echo -e "${CYAN}[Agents → ~/.qoder/agents/qoder-autopilot/]${NC}"

mkdir -p "$HOME/.qoder/agents/qoder-autopilot"
cp "$AGENT_SRC"/engineering-autopilot-*.md "$HOME/.qoder/agents/qoder-autopilot/"

# Verify agents
AGENTS_INSTALLED=$(ls "$HOME/.qoder/agents/qoder-autopilot"/engineering-autopilot-*.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$AGENTS_INSTALLED" -eq 7 ]; then
  echo -e "  ~/.qoder/agents/qoder-autopilot/: ${GREEN}$AGENTS_INSTALLED/7${NC}"
else
  echo -e "  ~/.qoder/agents/qoder-autopilot/: ${RED}$AGENTS_INSTALLED/7${NC}"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ─── Summary ───
if [ "$ERRORS" -eq 0 ]; then
  echo -e "${GREEN}Installation complete.${NC}"
  echo ""
  echo "  Skill:   ~/.agents/skills/qoder-autopilot/         (12 files)"
  echo "  Agents:  ~/.qoder/agents/qoder-autopilot/          (7 files)"
  echo ""
  echo "Trigger: qoder-autopilot / 自动开发 / 全自动 / autopilot / 端到端开发"
  echo ""
  echo -e "${CYAN}v9.6 changes from v9.5 (Anthropic harness-design alignment):${NC}"
  echo "  - Phase 3B AC negotiation: reviewer fast-mode evaluates every AC (CLEAR/AMBIGUOUS/UNCOVERED/CONTRADICTORY); planner §2f single corrective replan"
  echo "  - Phase 4A.5 task-level micro-loop: conditional on T_contract_* or touches_field_mapping_boundary; reviewer THIN MODE; max 2 refine cycles"
  echo "  - Field Mapping split: designer §2c ≤12-line direction declaration → implementer §1e grep-anchored Evidence Table → reviewer diff (generation/evaluation separation)"
  echo "  - Per-Skill Sub-Artifact protocol: reviewer writes evidence to review_artifact_dir/batch-N-*.md; main report stays compact"
  echo "  - Calibration Anchors: every 0-10 self-rating dimension carries 2/5/8 examples; score 10 reserved (anti-leniency drift)"
  echo "  - Layer ROI table (14 layers × 3-run rolling window) + Ablation Run protocol (only admissible evidence for layer removal)"
  echo "  - Harness Assumption Snapshot in retro (model/env drift detection)"
  echo "  - Phase 6 Checklist E (9 rows: AC review / corrective replan / DAG tagging / micro-loop coverage / Evidence Tables / sub-artifacts / ROI / snapshot / ablation)"
  echo "  - Implementer §1g Corrective-Findings Loop Handler (re-dispatch from micro-loop)"
  echo "  - Mandatory skills: 12 → 13 (frontend-design now an explicit row; rest unchanged)"
  echo "  - FAILURE MODES: 16 → 23 (+18 AC ambiguity, +19 cross-layer batch cascade, +20 design over-spec cascade, +21 no data for layer removal, +22 empty-shell agent/interface output, +23 implementation vs requirements gap)"
  echo "  - Global Rules: 18 → 26 (+20 calibration anchor citation, +21 sub-artifact discipline, +22 ablation safety, +23 per-task model tier, +24 intent-injection propagation, +25 data presence gate, +26 requirements coverage 95% floor)"
  echo "  - Typical dispatches: 6-9 → 7-11 (3B always; 4A.5 only when triggered)"
  echo ""
  echo -e "${CYAN}v9.6.1 quality-of-ship hardening (included):${NC}"
  echo "  - Data presence gate: FAILURE 22 — empty-shell agent/interface output is rejected before downstream phases consume it"
  echo "  - Cross-layer field mapping hardening: designer §2c requires representative endpoint/field pairs; implementer §1e Evidence Table carries endpoint + declared_conversion + contract_match + field_mapping_all_match; Phase 4A orchestrator rejects any mismatched row; reviewer/micro-loop emit structured field_mapping_diff JSON"
  echo "  - Requirements traceability gate: FAILURE 23 + Global Rule 26 — planner §2d produces requirements_traceability.matrix; implementer reports covered_requirements; Phase 4A aggregates coverage and blocks if MUST+SHOULD < 95%; Phase 5B verifier runs independent RTV and triggers auto-fix loop (max 2 cycles) when gap > 5%"
  echo ""
  echo -e "${CYAN}v9.7.0 (Complexity Ratchet — harness anti-bloat governance):${NC}"
  echo "  - Complexity Ratchet: the harness may grow ONLY if the same release names a DROP/MERGE candidate (FAILURE 21 defense / Global Rule 22)"
  echo "  - Landed by EXTENSION, not new counts — FAILURE 21 FIX + Global Rule 22 extended; net failure/rule delta = 0 (walk-the-talk)"
  echo "  - Phase 7 Complexity Ratchet Ledger (net-layer delta + forced DROP/MERGE proposal) + per-layer falsifiable harness assumption table"
  echo "  - reference.md §Complexity Ratchet: EXTEND > MERGE > ADD preference order + redundancy heuristic"
  echo "  - First DROP/MERGE candidate named: FAILURE 14 field-mapping 7 layers → merge to ≤3 in v9.7.1 (ablation-validated)"
  echo ""
  echo -e "${CYAN}v9.7.1 (Complexity Ratchet's FIRST real cut — field mapping 7 layers → 3 roles):${NC}"
  echo "  - FAILURE 14 defense merged to 3 roles: CONTRACT (scan+declare) / EVIDENCE (grep table) / GATE (deterministic 4A + independent 4B)"
  echo "  - Removed the redundant micro-loop LLM field diff (old L6); added a deterministic file:line grep spot-check inside the 4A gate (lossless)"
  echo "  - 4A.5 micro-loop trigger narrowed to T_contract_*; frontend-designer §2g demoted to authoring guidance"
  echo "  - canonical layer_roi 21 → 19 (net −2, first NEGATIVE delta — the ratchet demonstrably works)"
  echo "  - Two independent gates remain (deterministic 4A + independent 4B) — FAILURE 14 stays defended"
  echo ""
  echo -e "${CYAN}v9.7.2 (install layout unification):${NC}"
  echo "  - Agents install into ~/.qoder/agents/qoder-autopilot/ (subdirectory), no longer the agents root"
  echo "  - Skills install ONLY into ~/.agents/skills/qoder-autopilot/ — the ~/.qoderwork mirror/symlink is no longer created and old copies are cleaned up"
  echo "  - Runtime protocol unchanged — install/distribution layer only"
else
  echo -e "${RED}Installation finished with errors. Check output above.${NC}"
  exit 1
fi
