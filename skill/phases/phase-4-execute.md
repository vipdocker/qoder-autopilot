<!-- version: 9.6.0 -->
# Phase 4: EXECUTE + REVIEW

**THREE mandatory parts per batch in v9.6: 4A (implement) → 4A.5 (conditional micro-loop) → 4B (batch review).**

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
       Assignment: { task_id, description, estimated_files, dependencies, plan_doc_path,
                     frontend_spec_path (if has_frontend, else omit), project_path,
                     touches_field_mapping_boundary: bool  // v9.6: derived from plan_doc
                                                           // tags; planner sets this on
                                                           // T_contract_* / cross-layer tasks
                   }
       ⚠️ IF has_frontend: frontend_spec_path MUST be included — implementer needs it for UI tasks.
       ⚠️ IF touches_field_mapping_boundary=true: implementer MUST produce
          §1e Field Mapping Evidence Table (grep-produced) in its report.
    2. CHECK report status: PASS or FAIL
       → If FAIL with clear error: re-dispatch ONCE with error context
       → If FAIL twice: mark task BLOCKED, surface to user
    3. VERIFY (DATA PRESENCE — FAILURE 22 guard):
       When status indicates DONE/DONE_WITH_CONCERNS, the task MUST have produced
       actual changes:
         • files_modified + files_added MUST NOT both be empty
         • lines_changed SHOULD be > 0 (0 lines with empty file list = empty shell)
       IF empty → DO NOT mark done. Classify as MALFORMED, re-dispatch ONCE with:
         "Previous attempt returned DONE but change_registry is empty. Either implement
          the requested change or report BLOCKED with a concrete reason. Empty
          change_registry with DONE status is not allowed."
    4. VERIFY: frontend_aesthetics field present in report (APPLIED if UI files, else N/A)
    5. VERIFY (v9.6): IF touches_field_mapping_boundary=true → report MUST contain
       field_mapping_evidence_table (grep-anchored). Missing → re-dispatch ONCE with
       explicit instruction to produce it.
    6. VERIFY (FIELD MAPPING CORRECTNESS — FAILURE 14/22 guard):
       IF report contains field_mapping_evidence_table:
         • EVERY row MUST have contract_match="YES" (or matches_contract=true)
         • field_mapping_all_match MUST be true
         • mismatch_count MUST be 0
       IF any mismatch found:
         → DO NOT mark task done. Classify as CODE failure.
         → Re-dispatch implementer ONCE with corrective instruction:
           "Field Mapping Contract violation detected in your evidence table:
            {list mismatched rows}. Fix the implementation so every cross-boundary
            field honors the design doc contract, then re-run §1e and report
            field_mapping_all_match=true with zero mismatches."
         → If still mismatch after corrective retry → mark BLOCKED and surface to user.
    7. Update state: dag[id].status, dag[id].proofs, change_registry[id],
       dag[id].touches_field_mapping_boundary
       → IF frontend_aesthetics == APPLIED: skills_invoked += [frontend-design]

  ⛔ ALL tasks in batch must be DONE before proceeding to 4A.5 / 4B.
```

## ⛔ Phase 4A.5: TASK-LEVEL MICRO-LOOP → Task() — CONDITIONAL (v9.6)

**Purpose: catch contract drift on high-risk tasks BEFORE the batch reaches the full reviewer.
Mirrors Anthropic harness-design generator-evaluator loop *inside* a task boundary, not just
at batch boundary. Prevents Failure 19 (cross-layer cascade within batch).**

AGENT: `engineering-autopilot-reviewer.md` (THIN MODE — see agent §Thin Mode for Micro-Loop)
TRIGGERS (any of):
  - task.id matches `T_contract_*`
  - task.touches_field_mapping_boundary == true
  - task touches BOTH backend serializer AND frontend consumer files (cross-layer)
LIMIT: max 2 refine cycles per task. Counts against `state.dag[id].micro_loop_attempts`.

```
  FOR each task in batch where micro-loop TRIGGER matched:
    cycle = 0
    WHILE cycle < 2:
      1. DISPATCH reviewer in THIN MODE:
         Assignment: {
           mode: "micro_loop",
           task_id,
           change_registry_for_task: { files added/modified BY THIS TASK ONLY },
           design_doc_path,
           research_brief_path,  // for Baseline Signature + API Field Naming blocks
           project_path
         }
         THIN MODE skill scope: ONLY runs (a) Spec-compliance for this task's AC,
         (b) Field Mapping Contract diff (research_brief naming convention + design doc
         contract vs implementer's field_mapping_evidence_table; produce field_mapping_diff
         JSON with mismatched fields, severity, and concrete fix), (c) Sibling signature
         consistency for the new symbol.
         SKIPS: full ast scan, security audit, deployment-chain audit (those run in 4B).
         ⛔ If micro-loop finds ANY field_mapping_diff.mismatched > 0 → verdict MUST be
           REFINE_REQUIRED (or FAIL if unfixable). Do NOT let mismatched field names pass.
      2. CHECK micro_loop_verdict: PASS / REFINE_REQUIRED / FAIL
         → PASS: break loop, record state.dag[id].micro_loop_result = "PASS@cycle{n}"
         → REFINE_REQUIRED: re-dispatch implementer for THIS task ONLY with the
           reviewer's findings as `corrective_findings` field. Increment cycle.
         → FAIL: mark task BLOCKED with micro_loop_result = "FAIL", surface to user.
      3. state.dag[id].micro_loop_attempts = cycle + 1
    END WHILE
    IF cycle == 2 AND verdict still REFINE_REQUIRED:
      → Promote to BLOCKED, surface in 4B (do NOT silently accept).

  Record per task: state.dag[id].micro_loop = { triggered: bool, attempts, result }
  Aggregate: state.micro_loop_summary = { triggered_count, pass_count, refine_count, fail_count }
```

**Cost rationale**: micro-loop runs ONLY on the ~10-20% of tasks tagged as contract/cross-layer.
For each triggered task, thin-mode reviewer is ~1/4 the token cost of full 4B review because
ast/security/deployment-chain are deferred. Net cost increase < 10% per batch; net defect-escape
reduction ≥ 60% on contract surfaces (measured via retro Layer ROI).

## ⛔⛔ Phase 4B: REVIEW BATCH → Task() — MANDATORY ⛔⛔

**v6.0 executed ZERO batch reviews. DO NOT REPEAT THIS.**

AGENT: `engineering-autopilot-reviewer.md` (FULL MODE)
REQUIRED SKILLS: `requesting-code-review`, `ast-code-analysis-superpower`, `receiving-code-review`, `cso`
ASSIGNMENT: task IDs in batch, change_registry for batch tasks, design doc path, frontend_spec path (if has_frontend), project path, micro_loop_summary (v9.6)

```
    1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
       Agent file: ~/.qoder/agents/engineering-autopilot-reviewer.md
       Assignment: { mode: "batch_full", task_ids, change_registry_for_batch,
                     design_doc_path, frontend_spec_path (if has_frontend, else omit),
                     project_path, micro_loop_summary (from 4A.5),
                     review_artifact_dir }  // v9.6: per-skill sub-artifact dir
       ⚠️ design_doc_path MUST be included — reviewer performs spec-compliance check FIRST.
       ⚠️ IF has_frontend: frontend_spec_path MUST also be included — reviewer checks UI compliance.
       ⚠️ v9.6 PER-SKILL SUB-ARTIFACT PROTOCOL: reviewer MUST write each skill's full output
          to a separate file under review_artifact_dir, and surface only the per-skill
          verdict + path in the main report. This keeps the orchestrator report compact
          while preserving full evidence for retro / audit:
            - {dir}/batch-{N}-requesting-code-review.md
            - {dir}/batch-{N}-ast-analysis.md
            - {dir}/batch-{N}-receiving-code-review.md
            - {dir}/batch-{N}-cso.md
            - {dir}/batch-{N}-spec-compliance.md
            - {dir}/batch-{N}-security-audit.md
          Main report references these via path; the in-report summary is ≤ 5 lines per skill.
    2. VERIFY: report has ALL 4 proofs:
       requesting-code-review ✓, ast-code-analysis-superpower ✓, receiving-code-review ✓, cso ✓
       AND each proof has a `sub_artifact_path` pointing to the on-disk evidence file.
    3. VERIFY: Spec-Compliance Summary present with per-requirement verdicts
       Any MISSING/DIVERGED requirement → Batch Gate FAIL (blocking)
    4. VERIFY: Security Audit summary present (security_audit field in JSON)
       Any CRITICAL security finding → Batch Gate FAIL (blocking)
    5. Check Batch Gate: PASS/FAIL
    6. state.batch_reviews += [{
         batch: [ids],
         gate: "PASS/FAIL",
         spec_compliance: "X/Y",
         security_audit: "PASS/FAIL",
         proofs: {...},
         sub_artifacts: { requesting_code_review: "{path}", ast: "{path}", ... },  // v9.6
         micro_loop_summary_used: {...}  // v9.6: which micro-loop results were trusted
       }]
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
CHECK (v9.6): every task with touches_field_mapping_boundary=true OR id matching
  T_contract_* has state.dag[id].micro_loop.triggered == true.
IF not → YOU SKIPPED 4A.5 ON A QUALIFYING TASK. Go back and run the micro-loop for it.

CHECK (v9.6.1): REQUIREMENTS COVERAGE GATE (pre-Phase 5 early-catch):
  1. From planner output: requirements_traceability.matrix (list of req_ids)
  2. From all DONE/DONE_WITH_CONCERNS implementer reports: union of covered_requirements
  3. Compute:
       total_reqs      = count(matrix where criticality != NICE)  // MUST + SHOULD
       covered_reqs    = count(unique req_ids in covered_requirements that exist in matrix)
       missing_reqs    = total_reqs - covered_reqs
       coverage_ratio  = covered_reqs / total_reqs
  4. IF coverage_ratio < 0.95 OR any MUST requirement is in missing_reqs:
       → DO NOT proceed to Phase 5. This is a CODE/PLAN failure.
       → Re-dispatch planner ONCE with:
            corrective_mode: "requirements_coverage_gap"
            missing_requirements: [ {req_id, criticality, source, description} ]
            existing_dag: state.dag
            coverage_ratio: coverage_ratio
         Planner must produce a MINIMAL corrective plan that adds/extends tasks to cover
         the missing requirements. Then run Phase 4A on the corrective tasks and re-check.
       → IF coverage still < 0.95 after corrective pass → mark BLOCKED and surface to user.
  5. Record state.requirements_coverage = { total, covered, missing, ratio, gate: PASS/FAIL }
```
