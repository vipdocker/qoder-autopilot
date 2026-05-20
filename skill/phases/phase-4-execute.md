<!-- version: 9.5.2 -->
# Phase 4: EXECUTE + REVIEW

**TWO mandatory parts per batch: 4A (implement) and 4B (review).**

```
FOR each batch of READY tasks in DAG:
```

## Phase 4A: IMPLEMENT BATCH → Task() × N

AGENT: `engineering-autopilot-implementer.md`
REQUIRED SKILLS: `investigate` (on-fail), `frontend-design` (IF task touches UI files)
ASSIGNMENT per task: task ID, description, estimated files, dependencies, plan_doc path, frontend_spec path (if has_frontend), project path

```
  FOR each READY task (parallel where DAG allows):
    1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
       Agent file: ~/.qoder/agents/engineering-autopilot-implementer.md
       Assignment: { task_id, description, estimated_files, dependencies, plan_doc_path, frontend_spec_path (if has_frontend, else omit), project_path }
       ⚠️ IF has_frontend: frontend_spec_path MUST be included — implementer needs it for UI tasks.
    2. CHECK report status: PASS or FAIL
       → If FAIL with clear error: re-dispatch ONCE with error context
       → If FAIL twice: mark task BLOCKED, surface to user
    3. VERIFY: frontend_aesthetics field present in report (APPLIED if UI files, else N/A)
    4. Update state: dag[id].status, dag[id].proofs, change_registry[id]
       → IF frontend_aesthetics == APPLIED: skills_invoked += [frontend-design]

  ⛔ ALL tasks in batch must be DONE before proceeding to 4B.
```

## ⛔⛔ Phase 4B: REVIEW BATCH → Task() — MANDATORY ⛔⛔

**v6.0 executed ZERO batch reviews. DO NOT REPEAT THIS.**

AGENT: `engineering-autopilot-reviewer.md`
REQUIRED SKILLS: `requesting-code-review`, `ast-code-analysis-superpower`, `receiving-code-review`, `cso`
ASSIGNMENT: task IDs in batch, change_registry for batch tasks, design doc path, frontend_spec path (if has_frontend), project path

```
    1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
       Agent file: ~/.qoder/agents/engineering-autopilot-reviewer.md
       Assignment: { task_ids, change_registry_for_batch, design_doc_path, frontend_spec_path (if has_frontend, else omit), project_path }
       ⚠️ design_doc_path MUST be included — reviewer performs spec-compliance check FIRST.
       ⚠️ IF has_frontend: frontend_spec_path MUST also be included — reviewer checks UI compliance.
    2. VERIFY: report has ALL 4 proofs:
       requesting-code-review ✓, ast-code-analysis-superpower ✓, receiving-code-review ✓, cso ✓
    3. VERIFY: Spec-Compliance Summary present with per-requirement verdicts
       Any MISSING/DIVERGED requirement → Batch Gate FAIL (blocking)
    4. VERIFY: Security Audit summary present (security_audit field in JSON)
       Any CRITICAL security finding → Batch Gate FAIL (blocking)
    5. Check Batch Gate: PASS/FAIL
    6. state.batch_reviews += [{ batch: [ids], gate: "PASS/FAIL", spec_compliance: "X/Y", security_audit: "PASS/FAIL", proofs: {...} }]
    7. skills_invoked += [requesting-code-review, ast-code-analysis-superpower, receiving-code-review, cso]
    8. If Batch Gate FAIL → remediate findings, re-review
```

```
END FOR (next batch)
```

**⛔ HARD GATE before Phase 5:**
```
CHECK: state.json.batch_reviews is NOT empty
IF empty → YOU SKIPPED PHASE 4B. Go back and dispatch reviewer NOW.
```
