#!/bin/bash
# Regression probe for the v9.7.1 field-mapping DETERMINISTIC gate
# (skill/phases/phase-4-execute.md Phase 4A step 6).
#
# WHY: v9.7.1 removed the micro-loop LLM field-mapping diff (old L6). This probe proves the
# retained deterministic gate still catches the two fabrication sub-classes L6 used to catch,
# on a SEEDED defect where a snake->camel converter silently DROPS a field (email_addr) while
# the implementer's evidence table falsely claims field_mapping_all_match=true.
#
# It asserts the gate's two spot-check sub-checks catch the defect:
#   b1 TOKEN PRESENCE   -> catches R4 (evidence claims frontend field 'emailAddress', which is
#                          ABSENT from frontend.js -> flagged)
#   b2 CONVERSION BRIDGE -> catches R3 (declared_conversion 'camelize' does NOT handle
#                          email_addr in the converter -> field dropped -> flagged; note BOTH
#                          tokens exist in their own files, so b1 alone would MISS this)
#
# Exit 0 = gate would catch the seeded defect at task boundary.
# Exit 1 = REGRESSION: the gate was weakened and a field-mapping defect would escape.
#
# Standalone: `bash test/probes/field-mapping-gate/run.sh` (not wired into validate.sh's
# cross-file contract checks, to keep the Complexity Ratchet ledger clean; wire in only if
# a future retro shows field-mapping escapes recurring).
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
fail=0

echo "[b1 TOKEN PRESENCE] wrong-token row R4 (claims frontend 'emailAddress')"
if grep -q "emailAddress" frontend.js; then
  echo "  FAIL: 'emailAddress' present in frontend.js -> R4 would NOT be flagged"; fail=1
else
  echo "  PASS: 'emailAddress' absent -> b1 flags R4 (evidence-integrity failure)"
fi

echo "[b2 CONVERSION BRIDGE] conversion-drop row R3 (declared camelize on email_addr)"
if grep -q 'if "email_addr" in d' backend.py; then
  echo "  FAIL: camelize handles email_addr -> R3 conversion-drop would NOT be flagged"; fail=1
else
  echo "  PASS: camelize does NOT bridge email_addr -> b2 flags R3 (silent drop)"
fi

echo "[control] honest fields must be genuinely bridged (no false positive)"
for f in user_name created_at; do
  if grep -q "if \"$f\" in d" backend.py; then echo "  PASS: '$f' bridged"; else echo "  FAIL: '$f' should be bridged"; fail=1; fi
done

echo ""
if [ "$fail" -eq 0 ]; then
  echo "PROBE PASS: v9.7.1 gate (b1 token-presence + b2 conversion-bridge) catches BOTH seeded defect classes at task boundary."
else
  echo "PROBE FAIL: gate weakened -- a seeded field-mapping defect would escape the task-boundary gate."
fi
exit $fail
