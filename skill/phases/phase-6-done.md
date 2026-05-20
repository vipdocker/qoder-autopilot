<!-- version: 9.5.2 -->
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
| 12 | frontend-design-thinking       | IF FRONT  | YES/N/A | "Design Thinking: 6 dimensions" or "N/A — no frontend" |
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
    ✅ Self-Reflection: ZERO issues (or all remediated)
    ✅ Remediation cycles: {0/1/2}
```
