<!-- version: 9.7.2 -->
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
       Agent file: ~/.qoder/agents/qoder-autopilot/engineering-autopilot-implementer.md
       Assignment: { task_id, description, estimated_files, dependencies, plan_doc_path,
                     frontend_spec_path (if has_frontend, else omit), project_path,
                     touches_field_mapping_boundary: bool  // v9.6: derived from plan_doc
                                                           // tags; planner sets this on
                                                           // T_contract_* / cross-layer tasks
                   }
       ⚠️ IF has_frontend: frontend_spec_path MUST be included — implementer needs it for UI tasks.
       ⚠️ IF touches_field_mapping_boundary=true: implementer MUST produce
          §1e Field Mapping Evidence Table (grep-produced) in its report.
       Injected Skills (Global Rule 24): append state.injected_skills["implementer"] block
       (skill + why_match per item) to the assignment; omit if empty.
       ⚠️ MODEL ROUTING (v9.6.1 — Global Rule 23): read dag[task_id].recommended_model
          (cheap/standard/premium; missing → "standard") and dispatch on the mapped
          model tier — mapping table in reference.md §Model Tiers. Record
          state.dag[id].attempts[].model_used. Auto-escalate one tier after 2
          consecutive failures on the same task.
    2. CHECK report JSON status (v9.6.1 — 4-state, NOT legacy PASS/FAIL):
       → DONE: advance.
       → DONE_WITH_CONCERNS: advance; aggregate report.concerns[] into
         state.batch_concerns for the 4B reviewer assignment.
       → NEEDS_CONTEXT: re-dispatch SAME prompt + the context requested in
         needs_context[] (does NOT consume retry budget; max 2 cycles per task
         → then treat as BLOCKED).
       → BLOCKED: CODE-class — investigate & re-dispatch ONCE with more context;
         still BLOCKED → mark task BLOCKED, surface in batch assessment.
       → Legacy PASS/FAIL (pre-v9.6.1 report): PASS=DONE; FAIL → UNIVERSAL RETRY PROTOCOL.
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
    6. VERIFY (FIELD MAPPING CORRECTNESS — DETERMINISTIC GATE, FAILURE 14/22 guard):
       v9.7.1: this is the PRIMARY task-boundary field-mapping gate (it replaces the removed
       micro-loop LLM diff). It is DETERMINISTIC — no LLM — and runs on EVERY task carrying a
       field_mapping_evidence_table.
       IF report contains field_mapping_evidence_table:
         a. CONSISTENCY: EVERY row MUST have contract_match="YES" (or matches_contract=true),
            field_mapping_all_match MUST be true, mismatch_count MUST be 0.
         b. EVIDENCE SPOT-CHECK (v9.7.1 — catches fabricated / mistaken evidence rows,
            the sub-class the removed micro-loop used to catch). Two deterministic sub-checks:
            b1. TOKEN PRESENCE: each row's grep proof is "file:line". Read it (or grep the file)
                and confirm the claimed backend_field / frontend_field token ACTUALLY appears
                there. A proof that does not contain the claimed token = evidence-integrity
                failure → mismatch. (Catches typo'd / wrong field names.)
            b2. CONVERSION BRIDGE (v9.7.1a — closes the seeded-defect probe gap): IF a row's
                declared_conversion is a TRANSFORM (not "passthrough"/"none"), grep the declared
                conversion-boundary file and confirm the converter ACTUALLY maps this
                backend_field → frontend_field. A declared transform whose converter does not
                handle the field silently DROPS it → runtime undefined, even though BOTH tokens
                still exist in their own files (b1 alone cannot catch this) → mismatch.
       IF any mismatch OR any failed spot-check:
         → DO NOT mark task done. Classify as CODE failure.
         → Re-dispatch implementer ONCE with corrective instruction:
           "Field Mapping Contract violation / evidence-integrity failure detected:
            {list mismatched or unverifiable rows}. Fix the implementation (or correct the grep
            proof) so every cross-boundary field honors the design doc contract AND every row's
            file:line actually contains the claimed field; re-run §1e and report
            field_mapping_all_match=true with zero mismatches."
         → If still failing after corrective retry → mark BLOCKED and surface to user.
       Record state.layer_roi.field_mapping_gate (ran=true; caught_issue=true if any
       mismatch / spot-check failure).
    7. Update state: dag[id].status, dag[id].proofs, change_registry[id],
       dag[id].touches_field_mapping_boundary
       → IF frontend_aesthetics == APPLIED: skills_invoked += [frontend-design]

  ⛔ ALL tasks in batch must be DONE before proceeding to 4A.5 / 4B.
```

## ⛔ Phase 4A.5: TASK-LEVEL MICRO-LOOP → Task() — CONDITIONAL (v9.6)

**Purpose: catch contract drift on high-risk tasks BEFORE the batch reaches the full reviewer.
Mirrors Anthropic harness-design generator-evaluator loop *inside* a task boundary, not just
at batch boundary. Prevents Failure 19 (cross-layer cascade within batch).**

AGENT: `engineering-autopilot-reviewer.md` (THIN MODE — see agent "Section M — THIN MODE (Micro-Loop, Phase 4A.5)")
TRIGGER (v9.7.1 — narrowed to sibling-contract tasks ONLY):
  - task.id matches `T_contract_*`
  ⛔ Field-mapping / cross-layer tasks (touches_field_mapping_boundary=true) NO LONGER
     trigger the micro-loop. They are covered by the DETERMINISTIC field-mapping gate
     (Phase 4A step 6 above: evidence-table consistency + grep spot-check) plus the Phase 4B
     reviewer's independent Cross-Layer Field Mapping Check. The micro-loop now guards ONLY
     spec + sibling contract.
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
           research_brief_path,  // for Baseline Signature block
           project_path
         }
         THIN MODE skill scope (v9.7.1): ONLY runs (a) Spec-compliance for this task's AC,
         (b) Sibling signature consistency for the new symbol.
         SKIPS: field-mapping (now the DETERMINISTIC step-6 gate + 4B reviewer), full ast
         scan, security audit, deployment-chain audit (those run in 4B).
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
       Agent file: ~/.qoder/agents/qoder-autopilot/engineering-autopilot-reviewer.md
       Assignment: { mode: "batch_full", task_ids, change_registry_for_batch,
                     design_doc_path, frontend_spec_path (if has_frontend, else omit),
                     project_path, micro_loop_summary (from 4A.5),
                     concerns_from_implementers (v9.6.1 — aggregated concerns[] of
                       DONE_WITH_CONCERNS tasks in this batch, else omit),
                     review_artifact_dir }  // v9.6: per-skill sub-artifact dir
       Injected Skills (Global Rule 24): append state.injected_skills["reviewer"] block
       (skill + why_match per item) to the assignment; omit if empty.
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
CHECK (v9.7.1): every task with id matching T_contract_* has
  state.dag[id].micro_loop.triggered == true.
IF not → YOU SKIPPED 4A.5 ON A QUALIFYING (sibling-contract) TASK. Go back and run it.
CHECK (v9.7.1): every task with touches_field_mapping_boundary=true passed the
  DETERMINISTIC field-mapping gate (step 6: evidence-table consistency + grep spot-check).
IF not → the field-mapping gate was skipped; go back and run step 6 for it.

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
