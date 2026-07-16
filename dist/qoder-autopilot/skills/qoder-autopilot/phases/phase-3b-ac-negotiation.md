<!-- version: 9.6.1 -->
# Phase 3B: AC NEGOTIATION → Task() (reviewer fast mode)

**NEW in v9.6.** Maps to Anthropic harness-design "Sprint Contract negotiation" pattern.
Shifts spec-fuzziness failures from Phase 4B (expensive batch-level reject) to here
(cheap pre-flight). Failure 18 defense.

## Purpose

Before EXECUTE begins, validate that EVERY acceptance criterion in the plan_doc is
machine-verifiable by an evaluator. AC that cannot be verified produce unactionable
4B verdicts and force batch-level rework.

## Trigger

ALWAYS run between Phase 3 (PLAN) and Phase 4A (EXECUTE).
Skipping = violation of Global Rule 20.

## Protocol

AGENT: `engineering-autopilot-reviewer.md` (FAST MODE — see agent "Section N — FAST MODE (AC Negotiation, Phase 3B)")
REQUIRED SKILLS: (none — fast pre-flight, no external skill calls)
ASSIGNMENT: mode, plan_doc path, design_doc path, research_brief path, acceptance_criteria (extracted by orchestrator), project path

```
1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
   Agent file: ~/.qoder/agents/engineering-autopilot-reviewer.md
   Assignment: {
     mode: "ac_negotiation",
     plan_doc_path: "...",
     design_doc_path: "...",
     research_brief_path: "...",
     acceptance_criteria: [ ...AC list extracted from plan_doc by orchestrator... ],
     project_path: "..."
   }
   Injected Skills (Global Rule 24): append state.injected_skills["reviewer"] block
   (skill + why_match per item) to the assignment; omit if empty.
   Additional instructions in prompt:
     "FAST MODE: skip all code review / cso / ast / browser checks.
      Your single deliverable is the AC negotiation table — see your agent file's
      'Section N — FAST MODE (AC Negotiation, Phase 3B)' for the exact contract.
      Token budget: aim for <300 lines output."

2. PARSE result. Expected --- JSON --- block (canonical — matches agent Section N):
   {
     "mode": "ac_negotiation",
     "status": "DONE",
     "gate": "PASS|FAIL",
     "ac_negotiation_verdict": "PASS | REVISE_REQUIRED | FAIL",
     "ac_total": N, "ac_clear": N, "ac_ambiguous": N,
     "ac_uncovered": N, "ac_contradictory": N,
     "findings": [
       { "ac_id": 2, "verdict": "AMBIGUOUS|UNCOVERED|CONTRADICTORY", "fix": "..." }
     ]
   }

3. EVALUATE gate:
   - ac_negotiation_verdict == "PASS" (zero AMBIGUOUS/UNCOVERED/CONTRADICTORY)
     → gate PASS, proceed to STEP 5
   - == "REVISE_REQUIRED" → proceed to STEP 4 (planner corrective pass)
   - == "FAIL" (ACs structurally unverifiable, not a wording issue)
     → escalate to HUMAN GATE directly (skip STEP 4)

4. PLANNER CORRECTIVE PASS (max 1):
   Re-dispatch planner with assignment:
     {
       feature, design_doc_path, frontend_spec_path, has_frontend,
       project_path, research_brief_path,
       previous_plan_path: "{plan_doc_path}",
       ac_negotiation_findings: "{findings array — AMBIGUOUS/UNCOVERED/CONTRADICTORY rows}",
       corrective_instruction:
         "Phase 3B AC Negotiation found N AMBIGUOUS/UNCOVERED/CONTRADICTORY ACs.
          Apply your agent file §2e Corrective Replan Pass: rewrite AMBIGUOUS ACs to be
          machine-verifiable, add/expand tasks for UNCOVERED ACs, resolve CONTRADICTORY
          pairs (defer one with rationale). Do NOT restructure tasks that were CLEAR.
          Re-emit the full plan_doc."
     }
   After re-dispatch:
     a. Verify writing-plans proof again
     b. Re-dispatch reviewer fast-mode ONCE more on the updated plan_doc
     c. If gate now PASS → proceed to STEP 5
     d. If still FAIL → escalate to HUMAN GATE:
        "AC remains ambiguous after planner corrective pass. Manual review needed.
         {present the ambiguous ACs + reviewer's suggested missing info}"
        DO NOT advance to Phase 4 without resolution.

5. RECORD:
   - artifacts.ac_negotiation_result = "{path to ac-negotiation.md}"
   - state.layer_roi.phase3b_ac_negotiation = {
       ran: true,
       caught_issue: (ac_ambiguous + ac_uncovered + ac_contradictory > 0 at FIRST pass),
       finding_summary: "{1-line top finding, or null if all CLEAR}",
       effort_estimate: "LOW"
     }
   - Write state: { current_phase: "EXECUTE", ac_negotiation_result: {...} }

ON FAILURE → enter UNIVERSAL RETRY PROTOCOL (SKILL.md §UNIVERSAL RETRY PROTOCOL).
              Apply RETRY HINT below at STEP D (shrinkage).
```

## RETRY HINT (v9.6.1)

When Phase 3B reviewer dispatch fails at STEP D (PROMPT SHRINKAGE), use this MINIMAL variant:

```
SHRINKAGE MODE (use ONLY on retry STEP D):

⚠️ MINIMAL AC NEGOTIATION MODE. Earlier attempt failed (likely context overflow).
Produce ONLY the gate-blocking deliverable:

REQUIRED OUTPUT:
  --- JSON ---
  {
    "mode": "ac_negotiation",
    "status": "DONE",
    "gate": "PASS|FAIL",
    "ac_negotiation_verdict": "PASS | REVISE_REQUIRED | FAIL",
    "ac_total": N, "ac_clear": N, "ac_ambiguous": N, "ac_uncovered": N, "ac_contradictory": N,
    "findings": [ {ac_id, verdict, fix(<=20 words)} ]
  }
  --- END JSON ---

EXPLICITLY DROP:
  ❌ Do NOT echo the original AC text into findings — refer by ac_id only.
  ❌ Do NOT include design_doc commentary or proposed AC rewrites beyond the fix field.
  ❌ Do NOT include reviewer free-form analysis or rationale paragraphs.

KEEP IN OUTPUT CONTRACT:
  ✓ --- JSON --- block (above)
  ✓ One-sentence summary line above the JSON block
```

Rationale: AC negotiation is a near-pure parsing task with a tightly bounded output.
Shrinkage drops the human-readable narrative; the orchestrator only consumes the JSON.

⛔ DO NOT pre-emptively use shrinkage mode. Default assignment first; shrink only after STEP C fails.

## Reference

This phase implements Anthropic harness-design's "Sprint Contracts" pattern, adapted from
their full-stack 3-agent architecture:

> "Before each sprint, generator and evaluator negotiate what 'done' looks like.
>  The generator proposes what it will build and how success is verified;
>  the evaluator reviews. They iterate until agreement.
>  This bridges 'the gap between user stories and testable implementation.'"

In qoder-autopilot terms:
- "Generator" = planner agent
- "Evaluator" = reviewer agent (in fast mode)
- "Sprint" = entire EXECUTE phase (we don't decompose into sub-sprints; harness-design v2
  Opus 4.6 removed the sprint construct entirely — we follow the same simplification)
- "Negotiation" = single corrective pass (max 1), not free-form iteration; Phase 5B
  verification serves as the final external check
