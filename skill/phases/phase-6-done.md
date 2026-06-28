<!-- version: 9.6.0 -->
# Phase 6: DONE — Completion Report + Mandatory Self-Audit

## ⚠️ FIRST: Print Phase Start Checkpoint

```
┌─ PHASE 6 START ───────────────────────────────────────┐
│ 1. Did I Read this phase file?             YES         │
│ 2. Skills required this phase:             (audit)     │
│ 3. Resuming after compression?             YES → reload│
│ 4. skills_invoked so far: [{current list}]             │
│    COUNT: {N} skills called out of 12 tracked          │
│    ⚠️ If count < 10, something was DEFINITELY skipped  │
└────────────────────────────────────────────────────────┘
```

## Completion Report

Generate and save to `docs/superpowers/done-report-{date}-{feature}.md`:

```
## Harness Complete
Feature: {name}
Branch: {branch} -> merged via {strategy}

Delivery: {N} tasks, {Y} commits, {Z} files, +{add}/-{remove} lines
Quality: {outer_iterations} design revisions, {batch_iterations} replans, {task_retries} retries
Resource: {turns_used}/{budget} turns
DAG: {depth} levels, {parallel_groups} parallel groups, critical path: {task_ids}
User interventions: {count}

### Change Registry
{table of tasks → files modified}
```

---

## ⛔ MANDATORY COMPLETION SELF-AUDIT

**This is the final defense against skipped skills.** Complete ALL four checklists.
Print them in full. Do NOT abbreviate.

### Checklist A: Skill Invocations

For each skill, paste the ACTUAL first line of output you received.
"I remember calling it" is NOT evidence.

```
| #  | Skill                          | Required  | Called? | Proof (first line)               |
|----|--------------------------------|-----------|---------|----------------------------------|
|  1 | brainstorming                  | ALWAYS    | YES/NO  | "____"                           |
|  2 | writing-plans                  | ALWAYS    | YES/NO  | "____"                           |
|  3 | dispatching-parallel-agents    | ALWAYS    | YES/NO  | "____"                           |
|  4 | requesting-code-review         | ALWAYS    | YES/NO  | "____"                           |
|  5 | receiving-code-review          | ALWAYS    | YES/NO  | "____"                           |
|  6 | ast-code-analysis-superpower   | ALWAYS    | YES/NO  | "____"                           |
|  7 | cso                            | ALWAYS    | YES/NO  | "____"                           |
|  8 | finishing-a-development-branch | ALWAYS    | YES/NO  | "____"                           |
|  9 | benchmark                      | IF FRONT  | YES/N/A | "____" or "N/A — no frontend"    |
| 10 | investigate                    | IF FAIL   | YES/N/A | "____" or "N/A — no failures"    |
| 11 | health                         | ALWAYS    | YES/NO  | "____"                           |
| 12 | frontend-design-thinking       | IF FRONT  | YES/N/A | "Design Thinking: classify(2a) + 6-dim/0-10(2b) + state-matrix(2c) + slop-check(2d) + litmus(2e) + red-lines(2f)" or "N/A — no frontend" |
| 13 | frontend-design (gstack skill) | IF UI TASK | YES/N/A | "____" or "N/A — no UI files in any task" |
```

Count: `{called}` / `{required}` mandatory skills called.

**If count < 10 (no frontend, no failures) or < 13 (frontend project with UI tasks + failures), there are definitely skipped skills.**

### Checklist B: Artifacts

```
| # | Artifact                      | Phase    | Saved? | Path |
|---|-------------------------------|----------|--------|------|
| 1 | Research brief                | RESEARCH | YES/NO | ____ |
| 2 | Design doc                    | DESIGN   | YES/NO | ____ |
| 3 | Plan doc (with DAG)           | PLAN     | YES/NO | ____ |
| 4 | Done report                   | DONE     | YES/NO | ____ |
| 5 | Retro file                    | EVOLVE   | PEND   | (next phase) |
```

### Checklist C: Quality Gates

```
| # | Gate         | Phase   | Passed? | Evidence                      |
|---|------------- |---------|---------|-------------------------------|
| 1 | Task gate(s) | EXECUTE | YES/NO  | {pass}/{total} tasks          |
| 2 | Batch gate   | EXECUTE | YES/NO  | review_critical: {N}          |
| 3 | Finish gate  | FINISH  | YES/NO  | types: __, lint: __, build: __ |
```

### Checklist D: Human Gates

```
| # | Gate                   | Phase   | User replied? | Quote  |
|---|------------------------|---------|---------------|--------|
| 1 | Requirements confirmed | INTAKE  | YES/NO        | "____" |
| 2 | Design approved        | DESIGN  | YES/NO        | "____" |
| 3 | Batch checkpoint(s)    | EXECUTE | YES/NO        | "____" |
| 4 | Merge strategy chosen  | FINISH  | YES/NO        | "____" |
| 5 | Evolution proposals    | EVOLVE  | PENDING       | (next) |
```

### Checklist E: v9.6 Evidence (NEW)

Verify each v9.6 layer ran or was correctly skipped, with concrete state-file evidence.

```
| # | v9.6 Layer                              | Required           | Recorded? | Evidence                                        |
|---|------------------------------------------|--------------------|-----------|-------------------------------------------------|
| 1 | Phase 3B AC Negotiation                  | ALWAYS             | YES/NO    | state.ac_negotiation_result = "{PASS/REVISED}" |
| 2 | Phase 3B corrective pass (if REVISED)    | IF REVISED         | YES/N/A   | planner.corrective_pass_applied + findings_addressed |
| 3 | DAG per-task touches_field_mapping_boundary tagging | ALWAYS  | YES/NO    | state.dag_tagging_summary.cross_layer_tasks = {n} |
| 4 | Phase 4A.5 Micro-Loop ran on EVERY tagged task | IF n>0       | YES/NO    | for each tagged T_id: state.dag[T_id].micro_loop.triggered == true |
| 5 | Implementer §1e Field Mapping Evidence Table | IF tagged tasks present | YES/NO | each tagged task's report has field_mapping_evidence_table |
| 6 | Per-skill sub-artifact files written      | IF batch_full ran  | YES/NO    | review_artifact_dir contains batch-N-*.md files for each skill |
| 7 | Requirements Traceability Matrix produced | ALWAYS             | YES/NO    | state.requirements_traceability.matrix exists with req_ids |
| 8 | Requirements Coverage Gate passed         | ALWAYS             | YES/NO    | state.requirements_coverage.gate == "PASS" (ratio ≥ 0.95) |
| 9 | Phase 5B RTV ran                          | ALWAYS             | YES/NO    | state.verification_result.requirements_traceability.verdict exists |
| 10 | Layer ROI telemetry populated             | ALWAYS             | YES/NO    | state.layer_roi has entries for all canonical layer IDs |
| 11 | Harness Assumption Snapshot recorded      | ALWAYS             | YES/NO    | state.harness_assumption populated (model, reasoning_mode, …) |
| 12 | Ablation run executed (if scheduled)     | IF state.ablation_run.disabled_layer | YES/N/A | state.ablation_run.result = "SUCCESS|REVERTED" |
```

Source for each row:
- Read `state.json` for the recorded fields
- Read the on-disk review_artifact_dir for sub-artifacts
- Cross-check by sampling: pick 1 tagged task, verify its micro-loop dispatch
  shows up in state and its implementer report has the evidence table.

⛔ ANY row in Checklist E that is required and NO → STOP, run remediation loop below.

### Self-Reflection (answer honestly)

```
1. Did I start work in any phase WITHOUT proper preparation?
   → {YES: which / NO}
2. Did I skip any quality gate because things "seemed fine"?
   → {YES: which / NO}
3. Did I save ALL required documents?
   → {YES / NO: which missing}
4. Does skills_invoked contain ALL mandatory skills?
   → skills_invoked = [{actual array}]
   → Missing: {list or "none"}
5. Did I dispatch subagents WITHOUT injecting skill requirements?
   → {YES: which agents / NO}
6. Was this session affected by context compression? Did I recover properly?
   → {YES: what I recovered / NO / N/A}
```

### Remediation Loop

If ANY gap found:
1. STOP — do NOT transition to EVOLVE
2. Go back and fix each gap (call missing skills, save missing documents)
3. Re-run the FULL self-audit (all 4 checklists + all 6 questions)
4. Max 2 remediation cycles. If still failing → report to user with honest list of what's missing.

```
TRANSITION: DONE → EVOLVE
  Evidence:
    ✅ Report saved at {path}
    ✅ Checklist A: {called}/{required} — ALL PASS
    ✅ Checklist B: {saved}/{total} — ALL PASS
    ✅ Checklist C: {passed}/{total} gates — ALL PASS
    ✅ Checklist D: {confirmed}/{total} — ALL PASS
    ✅ Checklist E (v9.6): {recorded}/{required} — ALL PASS
    ✅ Self-Reflection: ZERO issues (or all remediated)
    ✅ Remediation cycles: {0/1/2}
```
