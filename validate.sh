#!/bin/bash
# Qoder Autopilot — Cross-File Contract Validation
# Usage: bash validate.sh [--quiet]
#
# WHY THIS EXISTS: the v9.6 upgrade shipped with orchestrator-side (phase files)
# and agent-side changes out of sync — the same "同族契约失配" failure class this
# pipeline defends against in user code (FAILURE 11/14). This script applies the
# L5 Contract Severity Matrix idea to the harness ITSELF: every phase↔agent
# interface is checked as a contract. Run before install and after any edit.
#
# Checks:
#   1. Version consistency  — SKILL.md canonical version == all phases/agents/docs
#   2. Mode contract        — every mode dispatched by phases exists in reviewer
#   3. Section anchors      — cross-file section references actually exist
#   4. JSON field contract  — fields the orchestrator parses exist in agent output contracts
#   5. JSON block presence  — every agent has a --- JSON --- block (Global Rule 9)
#   6. injection_used       — every agent JSON reciprocates Rule 24
#   7. layer_roi IDs        — canonical IDs (reference.md) all present in SKILL.md state
#   8. Agent file existence — every agent file referenced by skill files exists
#   9. Legacy token ban     — retired vocabulary must not reappear
#  10. Rule 24 propagation  — every Phase 1-5 dispatch carries the Injected Skills block

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/skill"
AGENT_SRC="$SCRIPT_DIR/agents"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

QUIET=0
[ "${1:-}" = "--quiet" ] && QUIET=1

PASS=0
FAIL=0

pass() {
  PASS=$((PASS + 1))
  [ "$QUIET" -eq 0 ] && echo -e "  ${GREEN}PASS${NC} $1"
  return 0
}

fail() {
  FAIL=$((FAIL + 1))
  echo -e "  ${RED}FAIL${NC} $1"
  return 0
}

section() {
  [ "$QUIET" -eq 0 ] && echo -e "${CYAN}[$1]${NC}"
  return 0
}

# ─── Pre-flight ───
if [ ! -f "$SKILL_SRC/SKILL.md" ] || [ ! -d "$AGENT_SRC" ]; then
  echo -e "${RED}Error: run from the package root (skill/SKILL.md + agents/ required).${NC}"
  exit 1
fi

# ═══ Check 1: Version consistency ═══
section "1. Version consistency"

CANON=$(grep -m1 '^version:' "$SKILL_SRC/SKILL.md" | awk '{print $2}')
if [ -z "$CANON" ]; then
  fail "SKILL.md has no frontmatter version"
else
  pass "canonical version = $CANON (from SKILL.md)"
fi

for f in "$SKILL_SRC"/phases/phase-*.md "$SKILL_SRC/reference.md" "$SKILL_SRC/self-check-protocol.md"; do
  V=$(grep -m1 -oE 'version: [0-9]+\.[0-9]+\.[0-9]+' "$f" | awk '{print $2}')
  if [ "$V" = "$CANON" ]; then
    pass "$(basename "$f") version $V"
  else
    fail "$(basename "$f") version '$V' != canonical '$CANON'"
  fi
done

for f in "$AGENT_SRC"/engineering-autopilot-*.md; do
  V=$(grep -m1 '^version:' "$f" | awk '{print $2}')
  if [ "$V" = "$CANON" ]; then
    pass "$(basename "$f") version $V"
  else
    fail "$(basename "$f") version '$V' != canonical '$CANON'"
  fi
done

# Banner/title versions (human-facing text drifts silently — check it too)
check_banner() {
  if grep -qF "$2" "$1" 2>/dev/null; then
    pass "$3 banner carries v$CANON"
  else
    fail "$3 banner does NOT carry v$CANON (update the title/header text)"
  fi
}
check_banner "$SKILL_SRC/SKILL.md"      "# Qoder Autopilot v$CANON" "SKILL.md H1"
check_banner "$SKILL_SRC/SKILL.md"      "description: \"v$CANON"   "SKILL.md description"
check_banner "$SCRIPT_DIR/README.md"    "# Qoder Autopilot v$CANON" "README.md H1"
check_banner "$SCRIPT_DIR/install.sh"   "Qoder Autopilot v$CANON"   "install.sh"
check_banner "$SCRIPT_DIR/uninstall.sh" "Qoder Autopilot v$CANON"   "uninstall.sh"

# README version-history table must contain a row for the canonical version
if grep -qE "^\| v$CANON " "$SCRIPT_DIR/README.md"; then
  pass "README.md 版本历史 has a v$CANON row"
else
  fail "README.md 版本历史 missing a v$CANON row (changelog not updated)"
fi

# ═══ Check 2: Mode contract (phase dispatch → reviewer mode selection) ═══
section "2. Mode contract"

REVIEWER="$AGENT_SRC/engineering-autopilot-reviewer.md"
# match ` mode: "x"` but NOT `corrective_mode: "x"` (planner-internal field)
MODES=$(grep -rhoE '(^|[^[:alnum:]_])mode: "[a-z_]+"' "$SKILL_SRC/phases" | grep -oE '"[a-z_]+"' | tr -d '"' | sort -u)
for m in $MODES; do
  if grep -qE "mode = \"$m\"|alias \"$m\"" "$REVIEWER"; then
    pass "mode \"$m\" dispatched by phases is handled by reviewer"
  else
    fail "mode \"$m\" dispatched by phases but NOT defined in reviewer mode selection"
  fi
done

# ═══ Check 3: Section anchors (cross-file references) ═══
section "3. Section anchors"

# check_anchor <source_file> <source_ref_pattern> <target_file> <target_anchor_pattern> <label>
check_anchor() {
  if grep -q "$2" "$1" 2>/dev/null; then
    if grep -q "$4" "$3" 2>/dev/null; then
      pass "$5"
    else
      fail "$5 — $(basename "$1") references it, but anchor missing in $(basename "$3")"
    fi
  else
    pass "$5 (reference not present — skipped)"
  fi
}

check_anchor "$SKILL_SRC/phases/phase-3b-ac-negotiation.md" "Section N" \
             "$REVIEWER" "^## Section N" \
             "phase-3b → reviewer 'Section N'"
check_anchor "$SKILL_SRC/phases/phase-4-execute.md" "Section M" \
             "$REVIEWER" "^## Section M" \
             "phase-4 → reviewer 'Section M'"
check_anchor "$SKILL_SRC/phases/phase-3b-ac-negotiation.md" "§2e" \
             "$AGENT_SRC/engineering-autopilot-planner.md" "^### 2e\." \
             "phase-3b → planner '§2e Corrective Replan Pass'"
check_anchor "$SKILL_SRC/phases/phase-2-design.md" "§2c" \
             "$AGENT_SRC/engineering-autopilot-designer.md" "^### 2c\." \
             "phase-2 → designer '§2c Field Mapping Contract'"
check_anchor "$SKILL_SRC/phases/phase-4-execute.md" "§1e" \
             "$AGENT_SRC/engineering-autopilot-implementer.md" "^### 1e\." \
             "phase-4 → implementer '§1e Field Mapping Evidence Table'"

# ═══ Check 4: JSON field contract (orchestrator-parsed fields exist in agent contracts) ═══
section "4. JSON field contract"

# require_field <agent_file> <field> — the agent's Output Contract must contain the field
require_field() {
  if grep -q "\"$2\"" "$1"; then
    pass "$(basename "$1") declares \"$2\""
  else
    fail "$(basename "$1") missing \"$2\" in Output Contract JSON"
  fi
}

require_field "$REVIEWER" "ac_negotiation_verdict"
require_field "$REVIEWER" "micro_loop_verdict"
require_field "$REVIEWER" "spec_stage"
require_field "$REVIEWER" "quality_stage"
require_field "$REVIEWER" "batch_gate"
require_field "$REVIEWER" "proofs_summary"
require_field "$AGENT_SRC/engineering-autopilot-implementer.md" "field_mapping_evidence_table"
require_field "$AGENT_SRC/engineering-autopilot-implementer.md" "needs_context"
require_field "$AGENT_SRC/engineering-autopilot-implementer.md" "concerns"
require_field "$AGENT_SRC/engineering-autopilot-researcher.md" "brief_path"
require_field "$AGENT_SRC/engineering-autopilot-designer.md" "field_mapping_declaration"
require_field "$AGENT_SRC/engineering-autopilot-frontend-designer.md" "frontend_spec"
require_field "$AGENT_SRC/engineering-autopilot-finisher.md" "finish_gate"
require_field "$AGENT_SRC/engineering-autopilot-finisher.md" "perf_baseline"

# planner emits per-task tags the orchestrator routes on (plain text, not JSON keys)
for tok in "recommended_model" "touches_field_mapping_boundary" "corrective_pass_applied"; do
  if grep -q "$tok" "$AGENT_SRC/engineering-autopilot-planner.md"; then
    pass "planner declares '$tok'"
  else
    fail "planner missing '$tok' (orchestrator routes on it)"
  fi
done

# ═══ Check 5 + 6: JSON block presence + injection_used (Global Rules 9 & 24) ═══
section "5+6. JSON block + injection_used in every agent"

for f in "$AGENT_SRC"/engineering-autopilot-*.md; do
  if grep -q -- "--- JSON ---" "$f"; then
    pass "$(basename "$f") has --- JSON --- block"
  else
    fail "$(basename "$f") missing --- JSON --- block (Global Rule 9)"
  fi
  if grep -q "injection_used" "$f"; then
    pass "$(basename "$f") reciprocates injection_used"
  else
    fail "$(basename "$f") missing injection_used (Global Rule 24)"
  fi
done

# ═══ Check 7: layer_roi canonical IDs (reference.md → SKILL.md state template) ═══
section "7. layer_roi canonical IDs"

LAYER_IDS=$(awk '/LAYER IDS \(canonical\):/{flag=1;next} /^$/{flag=0} flag{print $1}' "$SKILL_SRC/reference.md")
ID_COUNT=0
for id in $LAYER_IDS; do
  ID_COUNT=$((ID_COUNT + 1))
  if grep -q "\"$id\"" "$SKILL_SRC/SKILL.md"; then
    pass "layer id '$id' present in SKILL.md state template"
  else
    fail "layer id '$id' (reference.md canonical) missing from SKILL.md state template"
  fi
done
# reverse direction: SKILL.md must not carry layer ids that reference.md retired
SKILL_LAYER_COUNT=$(grep -cE '^    "(phase[0-9]|field_mapping)[a-z0-9_]*":' "$SKILL_SRC/SKILL.md")
if [ "$SKILL_LAYER_COUNT" -eq "$ID_COUNT" ]; then
  pass "layer id count in sync (reference.md $ID_COUNT == SKILL.md $SKILL_LAYER_COUNT)"
else
  fail "layer id count drift: reference.md canonical=$ID_COUNT vs SKILL.md state template=$SKILL_LAYER_COUNT"
fi

# ═══ Check 8: Agent file references resolve ═══
section "8. Agent file references"

REFS=$(grep -rhoE 'engineering-autopilot-[a-z-]+\.md' "$SKILL_SRC" | sort -u)
for r in $REFS; do
  if [ -f "$AGENT_SRC/$r" ]; then
    pass "referenced agent '$r' exists"
  else
    fail "skill files reference '$r' but agents/$r does not exist"
  fi
done

# ═══ Check 9: Legacy token ban ═══
section "9. Legacy token ban"

for tok in "ac_table" "ctp_peer_read" "sibling_scan" "verifier_5b" "cso_security" "benchmark_perf" "§1.5" "AMBIGUOUS/NO" "Thin Mode for Micro-Loop"; do
  HITS=$(grep -rn --fixed-strings "$tok" "$SKILL_SRC" "$AGENT_SRC" 2>/dev/null || true)
  if [ -z "$HITS" ]; then
    pass "no occurrences of retired token '$tok'"
  else
    fail "retired token '$tok' found:"
    echo "$HITS" | sed 's/^/         /'
  fi
done

# ac_negotiation_fast allowed ONLY on the reviewer's legacy-alias line
HITS=$(grep -rn "ac_negotiation_fast" "$SKILL_SRC" "$AGENT_SRC" 2>/dev/null | grep -v "legacy alias" || true)
if [ -z "$HITS" ]; then
  pass "'ac_negotiation_fast' only appears as reviewer legacy alias"
else
  fail "'ac_negotiation_fast' found outside the reviewer alias line:"
  echo "$HITS" | sed 's/^/         /'
fi

# ═══ Check 10: Rule 24 propagation in Phase 1-5 dispatches ═══
section "10. Injected Skills propagation (Global Rule 24)"

for p in phase-1-research phase-2-design phase-3-plan phase-3b-ac-negotiation phase-4-execute phase-5-finish; do
  N=$(grep -c "Injected Skills (Global Rule 24)" "$SKILL_SRC/phases/$p.md" 2>/dev/null || echo 0)
  if [ "$N" -ge 1 ]; then
    pass "$p.md carries Injected Skills block ($N dispatch site(s))"
  else
    fail "$p.md has NO Injected Skills block (Global Rule 24 requires it on every Phase 1-5 dispatch)"
  fi
done

# ─── Summary ───
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}Contract validation PASSED${NC} ($PASS checks)"
  exit 0
else
  echo -e "${RED}Contract validation FAILED${NC} ($FAIL failed / $PASS passed)"
  echo -e "Fix the drift above — phase files and agent files are a generator/consumer pair;"
  echo -e "shipping them out of sync reproduces FAILURE 11/14 inside the harness itself."
  exit 1
fi
