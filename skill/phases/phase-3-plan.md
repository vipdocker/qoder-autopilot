<!-- version: 9.6.0 -->
# Phase 3: PLAN → Task()

AGENT: `engineering-autopilot-planner.md`
REQUIRED SKILLS: `writing-plans`, `dispatching-parallel-agents`
ASSIGNMENT: feature, design_doc path, frontend_spec path (if applicable), has_frontend, project path

```
1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
   Agent file: ~/.qoder/agents/engineering-autopilot-planner.md
   Assignment: { feature, design_doc_path, frontend_spec_path (if has_frontend, else omit),
                 has_frontend, project_path, research_brief_path }
2. VERIFY: report has writing-plans proof ✓, dispatching-parallel-agents proof ✓
3. Extract: DAG, plan_doc path, requirements_traceability (v9.6.1 RTM)
4. skills_invoked += [writing-plans, dispatching-parallel-agents]
5. Write state: { current_phase: "AC_NEGOTIATION", dag: {...}, artifacts.plan_doc: "...", requirements_traceability: {...} }
6. ⛔ NEXT PHASE = Phase 3B (AC Negotiation). DO NOT jump to Phase 4 (EXECUTE).
   v9.6 inserts a mandatory contract-validation step between PLAN and EXECUTE — see
   `skill/phases/phase-3b-ac-negotiation.md`.

ON FAILURE → enter UNIVERSAL RETRY PROTOCOL (SKILL.md §UNIVERSAL RETRY PROTOCOL).
              Apply RETRY HINT below at STEP D (shrinkage).
```

## RETRY HINT (v9.5.4)

When the planner dispatch fails and STEP D (PROMPT SHRINKAGE) is reached, replace the
default assignment with this MINIMAL variant:

```
SHRINKAGE MODE (use ONLY on retry STEP D):

⚠️ MINIMAL PLAN MODE ENABLED. Earlier attempt failed (likely context overflow).
Produce ONLY the gate-blocking deliverables:

REQUIRED OUTPUT (do these — nothing else):
  1. DAG: nodes + depends_on edges. ID format T_NN. ALL tasks must have depends_on field
     (use [] for roots). T_contract_* tasks REQUIRED if 同族新实现 detected in design_doc.
  2. Per-task: { id, title (1 line), files_touched (paths only, no contents), depends_on }.
  3. Deployment-chain check: list any tasks that touch shared cache/build artifacts together.

EXPLICITLY DROP (do NOT include in plan_doc):
  ❌ Do NOT embed Baseline Signature Table content. Reference by path:
     "Baseline contracts: see {research_brief_path} §Baseline Signature Table"
  ❌ Do NOT enumerate full per-task acceptance criteria. Implementer (Phase 4A)
     reads research_brief + design_doc directly for AC; planner only owns DAG topology.
  ❌ Do NOT include risk analysis prose, alternative approaches, or planning rationale.
  ❌ Do NOT include human-readable narrative. Plan is consumed by orchestrator + implementers.

KEEP IN OUTPUT CONTRACT:
  ✓ --- JSON --- block with status, gate, dag_summary (count of T_*, count of T_contract_*)
  ✓ Skill proofs for writing-plans + dispatching-parallel-agents
  ✓ plan_doc path
  ✓ requirements_traceability matrix (v9.6.1 — keep concise: req_id, criticality, implementing_tasks only)

Token budget: aim for plan_doc ≤ 200 lines. Skeletal is acceptable.
```

Rationale: Phase 3 PLAN dispatch failures observed in practice trace to planner being asked
to embed full baseline signature tables + per-task ACs + DAG topology + rationale all in one
output. Cognitive + token load exceeds reliable single-pass capacity. Shrinkage moves
signature consumption to implementer (Phase 4A already reads research_brief in CTP Layer 4
"Peer Read-Before-Code") and AC tracking to design_doc (already authoritative source).
Planner's irreducible output = DAG topology. Everything else is duplicative and shrinkable.

⛔ DO NOT pre-emptively use shrinkage mode. It's a recovery path, not a default.
   Default assignment is the rich one — only fall to shrinkage after STEP A→B→C all fail.
