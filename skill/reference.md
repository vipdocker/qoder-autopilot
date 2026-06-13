<!-- version: 9.6.1 -->
# Reference Guide

Read this file when making quality gate, resource limit, or error classification decisions.
Version history & rationale for every rule below: see `README.md` (install-time only).

## Quality Gates

```
TASK GATE:    type_errors 0, lint_errors 0, build PASS, deploy_chain CLEAN
              (change-aware in EXECUTE, full in FINISH)
              ⛔ No test suite execution — verify by type/lint/build only.
              On self-verify FAIL, /investigate MUST be invoked before retry.

BATCH GATE:   all task gates PASS, review_critical 0, spec_compliance PASS,
              contract_consistency PASS (if 同族实现 in batch),
              security_audit PASS (/cso CRITICAL findings = BLOCKING)
              (spec-compliance covers BOTH design_doc AND frontend_spec)

FINISH GATE:  all batch gates PASS, types 0, lint 0, build PASS,
              browser PASS (if frontend), cache-bust CLEAN (if frontend),
              e2e_smoke PASS (if 同族新实现, else N/A),
              perf_baseline PASS (if frontend; HIGH regression = BLOCKING)
              ⛔ No test suite execution — type/lint/build catch the majority of regressions.
```

## Error Classification

```
Every failure MUST be classified before deciding retry strategy.
Parse error messages and agent reports against these patterns:

┌─────────────┬───────────────────────────────────────────────────────────────┬─────────────────────────┐
│ Class       │ Patterns                                                      │ Action                  │
├─────────────┼───────────────────────────────────────────────────────────────┼─────────────────────────┤
│ FATAL       │ 401, 403, "unauthorized", "forbidden", "permission denied",   │ STOP immediately.       │
│             │ "invalid token", "credit balance", "quota exceeded",           │ Mark BLOCKED.           │
│             │ "account suspended", "API key invalid"                         │ Surface to user.        │
│             │                                                               │ Do NOT retry.           │
├─────────────┼───────────────────────────────────────────────────────────────┼─────────────────────────┤
│ TRANSIENT   │ "timeout", "ECONNREFUSED", "rate limit", "429", "503",        │ WAIT with backoff:      │
│             │ "529", "socket hang up", "ECONNRESET", "service unavailable", │   30s → 60s → 120s     │
│             │ "temporarily unavailable", "overloaded", "try again later",   │ Max 3 retries.          │
│             │ agent produces no output at all (likely crash/idle timeout)   │ Then → SHRINKAGE.       │
├─────────────┼───────────────────────────────────────────────────────────────┼─────────────────────────┤
│ MALFORMED   │ JSON block missing/unparseable, required fields absent        │ CORRECTIVE retry        │
│             │ (status/gate/proofs_summary), output truncated mid-section,   │ (prefix + same          │
│             │ skill proof claims missing while output present, status field │  assignment).           │
│             │ empty, gate field empty, contradictory text vs JSON           │ Max 2. Then SHRINKAGE.  │
├─────────────┼───────────────────────────────────────────────────────────────┼─────────────────────────┤
│ CODE        │ Type errors, lint errors, build failures, logic bugs,         │ CORRECTIVE retry.       │
│             │ import errors, missing files, runtime exceptions,             │ Counts against          │
│             │ agent reports gate FAIL with non-transient cause              │ convergence limit.      │
│             │                                                               │ (high:3, med:2, low:1)  │
└─────────────┴───────────────────────────────────────────────────────────────┴─────────────────────────┘

Priority: FATAL > MALFORMED > TRANSIENT > CODE.
  Example: "unauthorized: process exited with code 1" → FATAL (not CODE).
  Example: agent timed out + output truncated → TRANSIENT (timeout is the root cause, not malformed output).

Edge cases:
  - Agent produces no output at all → classify as TRANSIENT (likely crash/timeout)
  - Agent produces partial output + error → classify based on error message
  - Agent produces full text but no --- JSON --- block → MALFORMED (use corrective retry, not transient)
  - 3 consecutive TRANSIENT retries all fail → escalate to PROMPT SHRINKAGE (not BLOCKED yet)
  - 2 consecutive CODE/MALFORMED corrective retries fail → escalate to PROMPT SHRINKAGE
  - SHRINKAGE retry fails → BLOCKED, surface attempts trace
  - ENV_FAILURE (dependency corrupt, OOM) → auto-repair once, then reclassify as CODE
  - See SKILL.md §UNIVERSAL RETRY PROTOCOL for the full decision tree binding these rules.
```

## Model Tiers

```
Premium:    designer, frontend-designer, planner, implementer, reviewer
            → Creative decisions, code generation, code review, security audit

Kimi-K2.5:  researcher
            → Search + synthesis (lower reasoning requirement)

Kimi-K2.6:  finisher
            → Branch prep + perf baseline + static checks (procedural, lower reasoning)

Override: if a non-Premium agent fails twice on the same task, escalate to Premium.
```

## Resource Limits

```
Per task:   80 turns, 30 min, 5 min idle timeout
Per batch:  300 turns, 90 min
Total:      1500 turns
On timeout: FORCE STOP, mark TIMEOUT, escalate to BATCH-ASSESS
```

## Idle Timeout

```
Definition: agent produces no output (no text, no tool calls) for a continuous period.

Per-task idle timeout: 5 minutes
  → If agent is silent for 5 minutes straight, ABORT the dispatch.
  → Mark as TRANSIENT failure (agent likely stuck/crashed).
  → Retry once. If idle again → mark BLOCKED, surface to user.

Rationale: without idle detection, a stuck agent burns 30 minutes of total timeout
doing nothing. Idle timeout catches this after 5 minutes, saving 25 minutes.

Implementation note: this relies on the host platform's idle detection.
If not available (no streaming telemetry), fall back to total timeout only.
```

## Convergence Safeguards

```
Task:   max retries by confidence (high:3, medium:2, low:1)
        ⚠️ Only CODE-class errors count. TRANSIENT retries are separate.
        ⚠️ MALFORMED corrective retries: max 2, then escalate to SHRINKAGE.
Batch:  max 2 replans, must show improvement
Design: max 2 outer iterations
Oscillation: same/worse quality after retry → STOP
Resource: total_turns > budget → STOP, full report
Retry escalation chain: TRANSIENT×3 → CORRECTIVE×2 → SHRINKAGE×1 → BLOCKED.
                        Each layer's exhaustion triggers the next, not BLOCKED directly.
```

## DAG Scheduling Rules

```
Unlock:     task READY when ALL depends_on have status "done"
Dispatch:   all READY tasks in parallel via dispatching-parallel-agents
Failure:    if task fails, downstream dependents BLOCKED
Escalation: BLOCKED tasks reported in batch assessment
Replanning: on outer loop rewind, DAG may be restructured
```

## Change-Aware Verification

```
EXECUTE phase: verify FOCUSED on changed files + 1-hop imports (type/lint/build)
FINISH phase:  verify FULL scope type/lint/build (no test suites — too slow and expensive)
Track:         change_registry[task_id] = { files_modified, files_added, lines_changed }
Review:        provide change_registry to code review for focused inspection
```

## Mandatory Human Gates

1. Requirements confirmation (Phase 0)
2. Design approval (Phase 2)
3. Batch checkpoint (Phase 4, after each passing batch)
4. Escalation decisions (when loops exhaust retries)
5. Merge strategy (Phase 5, before merge)
6. Evolution proposals (Phase 7)
+  Event-driven: user can intervene at ANY time

## Structured Output Parsing

```
Every agent MUST append a --- JSON --- block at the end of their report.

Format:
  --- JSON ---
  { "status": "PASS", "gate": "PASS", ... }
  --- END JSON ---

Parsing priority:
  1. Find "--- JSON ---" marker in agent output
  2. Extract JSON between markers
  3. Parse as JSON → use as authoritative result
  4. IF JSON parsing fails or marker missing:
     → Fall back to text extraction (legacy behavior)
     → Log: "WARNING: JSON block missing/invalid from {agent}"

Benefits:
  - Eliminates ambiguous text interpretation (FAILURE 8)
  - Gate decisions become deterministic (parse field, not guess from prose)
  - Enables future tooling (dashboards, trend analysis)
```

## Contract Consistency

```
Definition: "同族实现" (family members) = multiple implementations of the same
  abstraction/interface/role. Examples:
    - SinaDAO + StooqDAO + XueqiuDAO (all implement QuoteDAO interface)
    - EmailNotifier + SlackNotifier + SMSNotifier (all implement Notifier)
    - PostgresRepo + MongoRepo + RedisRepo (all implement DataRepo)

Four categories of contract mismatch bugs:
  ┌──────────────────────┬─────────────────────────────────────────────────────┐
  │ Category             │ Example                                             │
  ├──────────────────────┼─────────────────────────────────────────────────────┤
  │ Type contract        │ str "2026-01-01" vs datetime.date(2026,1,1)         │
  │ Semantic contract    │ UTC timestamp vs local timezone                     │
  │ Exception contract   │ returns None vs returns [] vs raises NotFoundError  │
  │ State contract       │ idempotent vs non-idempotent, stateful vs stateless │
  └──────────────────────┴─────────────────────────────────────────────────────┘

Characteristic: single-module unit tests 100% pass, cross-module integration BREAKS.
This is the most common bug class that unit-test-focused pipelines miss entirely.

Pipeline coverage (6-layer defense):
  Phase 1 Researcher:    Baseline Signature Table (existing family contract snapshot)
  Phase 2 Designer:      Explicit Contracts chapter (new impl schema declared)
  Phase 3 Planner:       T_contract_* task in DAG (dedicated verification node)
  Phase 4 Implementer:   Peer Read-Before-Code (reads sibling, self-checks diff)
  Phase 4B Reviewer:     Contract Severity Matrix (mismatch = BLOCKER)
  Phase 5 Finisher:      E2E Smoke Test (real call chain, not isolated unit)

Key principle:
  "跨实现契约一致性" 从隐式关注点升格为流水线的一等公民。
  有 Owner (researcher/designer), 有 Task (planner T_contract),
  有 Gate (reviewer BLOCKER + finisher E2E smoke).
```

## Calibration Anchors (for self-rating layers)

```
Anthropic's harness-design article observes: self-evaluation drifts lenient over time
unless calibrated against concrete examples. Agents rating their own output on a 0-10
scale produce inflated scores because there is no shared baseline for "what a 3 vs 7
actually looks like".

Affected layers in this pipeline:
  - Phase 2B frontend-design-thinking 6-dim/0-10 self-rating
  - Phase 4A implementer self-check (informal confidence)
  - Phase 4B reviewer severity tagging (CRITICAL/HIGH/MED/LOW)

CALIBRATION ANCHOR PROTOCOL:
  Each scoring rubric MUST include 3 concrete examples per dimension:
    - one anchored at score 2 (clearly inadequate)
    - one anchored at score 5 (acceptable / minimum bar)
    - one anchored at score 8 (genuinely strong)
  The score 10 is reserved and SHOULD NOT be used in normal practice — its scarcity
  is the calibration. If an agent gives a 10, it must point to which extant work in
  the codebase reaches that bar.

CALIBRATION EXAMPLES (frontend-design 0-10):
  Dimension: Visual Hierarchy
    Score 2: flat list, no size/weight/color distinction between primary and secondary
      actions; user can't tell what to do first.
    Score 5: primary CTA visually distinct (larger / accented color), secondary actions
      muted; hierarchy works but lacks polish (e.g., uneven spacing).
    Score 8: matches reference component (e.g., StockAnalysis sidebar item active state)
      in size + color + spacing rhythm; primary action draws eye within 1 second of glance.

  Dimension: State Coverage
    Score 2: only happy-path designed; missing empty / loading / error / disabled states.
    Score 5: empty + loading designed; error/disabled defaulted to browser style or omitted.
    Score 8: empty / loading / error / disabled / success / partial / focus / hover all
      designed AND consistent with project conventions (uses project's existing skeleton
      pattern, error toast, focus ring tokens).

  Dimension: Consistency with Project
    Score 2: introduces new color palette / font / spacing scale not in design tokens.
    Score 5: uses 80%+ design tokens but introduces 1-2 new hardcoded values.
    Score 8: 100% design tokens; component shape matches an existing sibling component
      family (cite sibling file path).

CALIBRATION EXAMPLES (reviewer severity):
  CRITICAL: security vuln (SQLi/XSS/auth bypass), data loss, breaks production,
    spec MISSING/DIVERGED on a hard requirement.
  HIGH:    contract mismatch with sibling, frontend spec DIVERGED, deployment-chain
    stale reference, missing error handling on user input boundary.
  MED:     code smell that complicates future change (deeply nested, magic number),
    inconsistent naming within new file, missing log on important branch.
  LOW:     style nit, redundant comment, minor naming taste.
  Recalibration rule: if 3 consecutive batches have ZERO CRITICAL findings AND
    integration tests later catch defects → reviewer is too lenient; bump one severity
    level on next batch's findings and audit the pattern.

Rationale: forces the rubric to be grounded in this codebase, not in abstract
"goodness". Prevents the calibration drift that the Anthropic article documents.
```

## Layer ROI Tracking

```
PURPOSE: collect per-layer telemetry so Phase 7 retro can build the Layer ROI table.
Without this, no rational layer-removal decision is possible (the Anthropic article's
single biggest point: harnesses grow monotonically because no one measures cost).

WHAT TO RECORD per run, per layer:
  state.layer_roi[<layer_id>] = {
    ran: bool,
    caught_issue: bool,            // did it surface a finding that would have caused
                                   // a downstream failure if absent?
    finding_summary: "...",         // 1 line if caught_issue=true, else null
    effort_estimate: "LOW|MED|HI"  // share of run's turn budget
  }

LAYER IDS (canonical):
  phase1_baseline_signature
  phase1_api_field_naming
  phase2a_field_mapping_contract
  phase2b_frontend_design
  phase3b_ac_negotiation
  phase4a5_micro_loop
  phase4b_requesting_code_review
  phase4b_ast_analysis
  phase4b_receiving_code_review
  phase4b_cso
  phase5a_finishing
  phase5b_verification
  phase6_self_audit
  phase7_health

WHEN TO RECORD:
  - At the end of each phase, update the relevant layer_roi entry.
  - Don't try to compute the verdict (KEEP/SHRINK/DROP) — Phase 7 retro does that.

AGGREGATION (Phase 7):
  - Read state.layer_roi from this run + last 2 retro files (.qoder-autopilot-retro.md
    parses prior layer_roi tables).
  - For each layer, compute 3-run rolling: caught_issue counts, effort_estimate mode.
  - Verdict logic:
      caught_issue across 3 runs == 0 AND effort > LOW → DROP candidate
      caught_issue ≥ 1 AND effort > MED → SHRINK candidate
      else → KEEP

⛔ NEVER auto-remove a layer based on ROI table alone. Always propose to human gate.
```

## Ablation Run Protocol

```
PURPOSE: provide the ONLY admissible evidence for permanent layer removal — actually
running with that layer disabled and seeing what happens.

WHEN TO PROPOSE:
  - Phase 7 retro Layer ROI table flags ≥1 DROP candidate
  - User approves the ablation at the evolution-proposals human gate

HOW TO RUN:
  1. At Phase 0 INTAKE of the NEXT feature, set:
       state.ablation_run = {
         disabled_layer: "<layer_id>",
         predicted_failure_mode: "<failure mode id from KNOWN FAILURE MODES>",
         hypothesis: "this layer no longer earns its cost on tasks of class X"
       }
       state.disabled_layer = "<layer_id>"
  2. Orchestrator: when it encounters the disabled layer's phase/skill, SKIP it
     and record state.layer_roi[<layer_id>].ran = false with notation "ablation".
  3. Continue the pipeline as normal — do NOT add compensating checks. The point
     is to see if the failure mode actually triggers.

WHAT TO MEASURE:
  - Did the predicted failure mode trigger anywhere downstream (4B reviewer, 5B
    verifier, finish gate, integration smoke)?
    YES → ablation REVERTED; restore layer immediately; tag its Layer ROI row
          with "ablation-confirmed-need"; do NOT propose removal again for 5 runs.
    NO  → ablation SUCCESS; layer is now a DROP candidate with evidence;
          if 2 consecutive ablations succeed → propose hard removal in next minor version.

RECORD in retro:
  state.ablation_run.result = "SUCCESS" | "REVERTED"
  state.ablation_run.evidence = "<which failure mode triggered, or 'none observed'>"

⛔ ABLATION SAFETY RULES:
  - Only ablate ONE layer per run. Never ablate two simultaneously.
  - Never ablate a HARD CORRECTNESS GATE (4B spec-compliance, 5A type/lint/build,
    5B sibling consistency on T_contract_*). These are baseline safety, not optional.
  - Eligible for ablation: layers that exist to catch a specific failure mode that
    has NOT triggered in the last 3 runs.
  - If feature is high-risk (production-critical, security-sensitive), defer ablation
    to a lower-risk feature.
```
