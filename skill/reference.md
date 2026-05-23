<!-- version: 9.5.4 -->
# Reference Guide

Read this file when making quality gate, resource limit, or error classification decisions.

## Quality Gates

```
TASK GATE:    type_errors 0, lint_errors 0, build PASS, deploy_chain CLEAN
              (change-aware in EXECUTE, full in FINISH)
              ⛔ No test suite execution — verify by type/lint/build only.
              v9.5: on self-verify FAIL, /investigate must be invoked before retry.

BATCH GATE:   all task gates PASS, review_critical 0, spec_compliance PASS,
              contract_consistency PASS (if 同族实现 in batch),
              security_audit PASS (v9.5: /cso CRITICAL findings = BLOCKING)
              (spec-compliance covers BOTH design_doc AND frontend_spec)

FINISH GATE:  all batch gates PASS, types 0, lint 0, build PASS,
              browser PASS (if frontend), cache-bust CLEAN (if frontend),
              e2e_smoke PASS (if 同族新实现, else N/A),
              perf_baseline PASS (v9.5: if frontend; HIGH regression = BLOCKING)
              ⛔ No test suite execution — type/lint/build catch the majority of regressions.
```

## Error Classification (v9.0)

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
│ (v9.5.4)    │ (status/gate/proofs_summary), output truncated mid-section,   │ (prefix + same          │
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

## Idle Timeout (v9.0)

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
        ⚠️ MALFORMED (v9.5.4) corrective retries: max 2, then escalate to SHRINKAGE.
Batch:  max 2 replans, must show improvement
Design: max 2 outer iterations
Oscillation: same/worse quality after retry → STOP
Resource: total_turns > budget → STOP, full report
Retry escalation chain (v9.5.4): TRANSIENT×3 → CORRECTIVE×2 → SHRINKAGE×1 → BLOCKED.
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

## Structured Output Parsing (v9.0)

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

## Contract Consistency (v9.1)

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
