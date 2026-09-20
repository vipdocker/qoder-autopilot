<!-- version: 9.7.2 -->
# Phase 7: EVOLVE — Skill Self-Evolution with Persistent Memory

## ⚠️ FIRST: Print Phase Start Checkpoint

```
┌─ PHASE 7 START ───────────────────────────────────────┐
│ 1. Did I Read this phase file?             YES         │
│ 2. Skills required this phase:             (none)      │
│ 3. Resuming after compression?             YES → reload│
│ 4. skills_invoked so far: [{current list}]             │
│ 5. Self-audit passed in Phase 6?           YES → proceed│
└────────────────────────────────────────────────────────┘
```

## What to Do

```
1. Aggregate retro_log from all tasks
2. Aggregate change_registry for impact analysis
3. Aggregate user_interventions for coordination insights
4. Identify patterns (threshold: same insight 2+ times)
5. Run Health Score (v9.5 — MANDATORY):
   Call Skill(skill="health")
   → /health produces a composite 0-10 code quality score:
     type-check score + lint score + test coverage + dead-code ratio
   → Record the score and per-dimension breakdown
   → Compare against previous runs' health scores (from earlier .retro.md entries)
   → Trend: IMPROVING / STABLE / DECLINING (if ≥2 prior runs exist)
   → If DECLINING for 2+ consecutive runs → flag as HIGH-priority evolution proposal
6. Draft evolution proposals:
   - Skill updates (e.g., "writing-plans should include X")
   - Confidence recalibration (e.g., "CRUD harder than expected")
   - Model tier adjustments
   - DAG pattern insights (e.g., "frontend tasks block integration")
   - Research gaps (e.g., "should have researched X before design")
   - Self-audit insights (e.g., "I consistently skip skill X")
   - Context compression lessons (e.g., "session ran out of context at Phase 4")
   - Health score trends (e.g., "lint score declining — new code not following conventions")
   - Complexity ratchet (v9.7): compute this run's net-layer delta; if any layer/skill/rule
     was ADDED this release, name ≥1 DROP/MERGE candidate (Global Rule 22). See ledger below.
6.5 COMPLEXITY RATCHET GATE (v9.7 — MANDATORY): fill the Complexity Ratchet Ledger.
    A release that grew the harness without naming a cut candidate = FAILURE 21 recurrence.
7. HUMAN GATE: Present proposals, apply on approval
8. Write PERSISTENT MEMORY to .qoder-autopilot-retro.md (project root) — APPEND this run's
   entry; NEVER overwrite prior entries.
9. ⛔ VERIFY THE APPEND (v9.7.1a — data-presence on the retro itself; FAILURE 22/23 guard):
   After writing, RE-READ .qoder-autopilot-retro.md and confirm it now PHYSICALLY contains
   THIS run's entry — grep for the feature name / run date AND this run's Layer ROI table.
     • Found → set state.retro_saved = true.
     • NOT found (write silently failed / wrong path / append skipped) → retry the append
       ONCE; if still missing, set retro_saved = false and surface "retro append FAILED" at
       the human gate. Do NOT advance to a clean DONE.
   ⛔ NEVER set retro_saved = true without confirming the entry is in the file. A true flag
     with no entry is a FALSE CLAIM (FAILURE 23) — it silently breaks the ratchet's 3-run
     trend, which aggregates prior retro files. (Observed: run #3 set retro_saved:true but
     appended nothing; the retro's last entry was still run #2.)
```

## Retro File Format (append-only, timestamped)

```markdown
## Run {date} — {feature_name}

### Key Insights
- {insight_1}
- {insight_2}

### Confidence Recalibrations
- {task_type}: {old_level} → {new_level}, reason: {reason}

### Model Tier Adjustments
- {adjustment}

### DAG Patterns
- {pattern}

### Research Lessons
- {what should have been researched}

### Self-Audit Results
- Skills called: {called}/{required}
- Remediation cycles: {N}
- Gaps found: {list or "none"}
- Skills most likely to be skipped: {pattern from this + previous runs}
- Context compression occurred: {yes/no, at which phase}

### Metrics
- Tasks: {done}/{total}, Retries: {N}, Turns: {used}/{budget}
- User interventions: {count}

### Requirement vs Implementation Delta (v9.3)
| Requirement | Acceptance Criterion | Status | Notes |
|-------------|---------------------|--------|-------|
| {req_1}     | {criterion}         | ✅ MET / ⚠️ PARTIAL / ❌ MISSED | ... |

Source: compare acceptance_criteria from state.json against change_registry.
Populate this table BEFORE proposing evolution proposals — missed requirements
should be filed as retrospective bugs, not "insights".

### Sibling Consistency Summary (v9.3)
| New Symbol | Sibling | Deviations Found | Impact |
|-----------|---------|-----------------|--------|
| {new_fn}  | {sibling} | {list or "none"} | NONE / TECH_DEBT / BUG |

Source: Phase 5B Sibling Contract Consistency Check.
Populate from state.verification_result.consistency_deviations.
Any DEVIATED item with BUG impact must generate a HIGH-PRIORITY evolution proposal.

### Health Score (v9.5)
```
| Dimension       | Score (0-10) | Notes                          |
|-----------------|--------------|--------------------------------|
| Type-check     | {n}          | {errors / clean}               |
| Lint           | {n}          | {warnings / clean}             |
| Test coverage  | {n}          | {if applicable / N/A}          |
| Dead code      | {n}          | {orphaned exports / clean}     |
| **Composite**  | **{n}**      | (weighted average)             |

Previous run score: {prev or "first run"}
Trend: IMPROVING / STABLE / DECLINING (over last 2-3 runs)
```

Source: Phase 7 /health skill invocation.
DECLINING for 2+ consecutive runs → HIGH-priority evolution proposal:
  "代码质量分持续下降——找出哪个维度退化最快，定位到最近的几个变更。"
```

### AC Negotiation Summary (v9.6)
```
| Aspect                         | Value                              |
|--------------------------------|-------------------------------------|
| Negotiation result             | PASS / REVISED / FAIL              |
| Corrective passes used         | {0/1}                              |
| Ambiguous AC items flagged     | {count}                             |
| AC items revised post-3B       | {count}                             |
| Time spent in 3B (turns)       | {n}                                |
```

Source: `state.json.ac_negotiation_result` + `state.json.ac_negotiation_findings`.
If REVISED, list the top ambiguity that triggered the rewrite.

### Task-Level Micro-Loop Summary (v9.6)
```
| Aspect                         | Value                              |
|--------------------------------|-------------------------------------|
| Tasks triggering micro-loop    | {n} of {total}                     |
| Pass@cycle1                    | {n}                                |
| Pass@cycle2                    | {n}                                |
| Refine cycles consumed         | {sum}                              |
| BLOCKED at micro-loop          | {n} (list)                         |
| Defects later caught in 4B     | {n} (escaped from micro-loop)      |
```

Source: `state.micro_loop_summary` + cross-reference with batch_reviews findings.
**Use this table for ROI**: if pass@cycle1 > 80% AND batch-4B finds no escapes for
micro-loop'd tasks for 3+ runs → propose lowering micro-loop trigger threshold.
If refine cycles consistently > 1.5 → propose strengthening implementer's §1e
evidence table format (more grep anchors).

### Layer ROI Table (v9.6 — MANDATORY)

**Purpose**: provide *evidence-based* data for layer-removal decisions.
The Anthropic article warns that pipelines grow monotonically; v9.5 added 13 mandatory
skills, 17 failure modes, 19 global rules. Without per-layer ROI data, no rational
removal decision is possible. This table fixes that.

```
| Layer / Skill / Gate           | Times Run | Caught Issue? | Effort Cost | Verdict |
|--------------------------------|-----------|---------------|-------------|---------|
| Phase 1 Baseline Signature     | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Field Mapping Contract         | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 2B frontend design       | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 3B AC Negotiation        | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 4A.5 Micro-Loop          | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Field Mapping Gate             | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 4B requesting-code-review| {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 4B ast-code-analysis     | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 4B receiving-code-review | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 4B cso                   | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 5A finishing             | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 5B verification          | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 6 Self-Audit             | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
| Phase 7 health                 | {n}       | YES/NO/N/A    | LOW/MED/HI  | KEEP/SHRINK/DROP |
```

**Methodology**:
- `Caught Issue?` = did this layer surface a finding that would have caused a failure
  if skipped? Read from the layer's proof/output: did it flag MISSING/DIVERGED/CRITICAL?
- `Effort Cost` = LOW (<5% turn budget), MED (5-15%), HI (>15%).
- `Verdict`:
  - KEEP: caught issue at least once across last 3 runs OR is a HARD CORRECTNESS GATE.
  - SHRINK: caught issue but cost > value; propose lighter form (e.g., spot-check
    not exhaustive).
  - DROP: 3 consecutive runs of NO/N/A AND cost > LOW → propose removal in v9.7.

**Drop policy**: a layer reaches the DROP verdict only after the table records 3+ runs
with no value. The retro must list the drop candidates and the human gate decides.
Do not auto-remove.

Source: aggregate per-phase proofs and state telemetry. A layer is "Run" if its
state field is populated AND non-empty for the run.

⛔ TELEMETRY-DRIFT FALLBACK (v9.7.1a): if state.layer_roi is drifted (retired / ad-hoc /
omitted keys — see reference.md §Layer ROI Tracking) or absent (e.g. a compressed run skipped
Phase 7 recording), DO NOT silently drop the trend. DERIVE each layer's ran / caught_issue from
sub-artifacts — dag[*].proof + .qoder-autopilot/reviews/** — map them onto the CANONICAL ids,
AND tag the run "telemetry-drift; ROI reconstructed" in the retro so the drift is visible and
gets fixed, not hidden.

### Intent Injection ROI (v9.6.1 — MANDATORY when Phase 0 §6.5 produced injections)

**Purpose**: close the loop on Phase 0 intent-recognition. Every injected skill is
an assumption about which extra knowledge the agent needs; without ROI feedback the
injection list grows monotonically (same FAILURE 21 trap as layers).

```
| Agent              | Skill Injected      | Times Available | Times Used | Verdict |
|--------------------|---------------------|-----------------|------------|---------|
| {agent}            | {skill}             | {dispatches}    | {n}        | KEEP/DEMOTE |
```

**How to populate**:
1. Read `state.injected_skills[<agent>]` for each agent — that is "Times Available"
   per dispatch (multiply by the dispatch count for that agent in this run).
2. Aggregate `injection_used:[]` arrays from every implementer + reviewer JSON
   report across all batches/tasks. Match by skill name.
3. `Verdict`:
   - KEEP: used at least once this run OR cumulatively used ≥1 across last 3 runs.
   - DEMOTE: cumulatively `fire_count > 0` AND `blocker_catch == 0` AND zero
     `INJECTION_USED` across the **last 3 runs** → propose removing the matching
     signal→skill rule from Phase 0 §6.5(c) candidate proposer for next run.
4. Update `state.layer_roi.intent_injection`:
   - `fire_count` += total injections proposed this run
   - `blocker_catch` += injected skills cited in a batch_reviews finding
   - `helped_phases` += phases where INJECTION_USED appeared with a PASS outcome

**Honesty rule**: do NOT inflate `Times Used` to justify keeping a skill. An empty
INJECTION_USED is signal, not failure. The injection itself may still have been
"watched" by the agent (read description) — that's already accounted for in
Times Available.

### Harness Assumption Snapshot (v9.6)

**Purpose**: record the *operating assumptions* this run was built on, so retro can
notice when the model/tool capability has drifted and the harness no longer matches.
Anthropic's article: "the harness encodes assumptions about the model — when the
model gets stronger, the assumptions may be obsolete".

```
| Assumption                                | This Run                     |
|-------------------------------------------|------------------------------|
| Default model tier                        | {tier}                       |
| Reasoning mode (high/medium/low/off)      | {mode}                       |
| Subagent model tier                       | {tier or "same"}             |
| Context window observed                   | {tokens}                     |
| Compression events                        | {n}                          |
| Skills considered mandatory               | {count}                      |
| Failure modes considered "always check"   | {count}                      |
```

Trend question for human gate: "Are any of the mandatory skills/failures only there
because of an OLDER, weaker model? Run an ablation in the next sprint to check."

**Per-layer falsifiable assumption (v9.7 — populate `state.harness_assumption.per_layer`)**:
For each defense layer, record the ONE model-capability assumption that justifies it, phrased
so an ablation can FALSIFY it. The single global assumption becomes per-layer, testable claims:

| Layer                          | Assumed model gap (falsifiable)                           |
|--------------------------------|-----------------------------------------------------------|
| phase4a5_micro_loop            | "model can't self-catch cross-layer field drift mid-task" |
| field_mapping_contract         | "model won't declare a naming boundary unprompted"        |
| phase4b_ast_analysis           | "model misses structural anti-patterns in review prose"   |

If a layer's assumption is no longer true under the current model → it becomes an ablation
candidate. Do NOT leave the assumption as a single vague line — one line per layer that runs.

### Complexity Ratchet Ledger (v9.7 — MANDATORY)

**Purpose**: enforce FAILURE 21 defense / Global Rule 22. The Anthropic article's single
biggest warning is that harnesses grow monotonically because nobody prices each layer. This
ledger makes every release account for its net complexity: the harness may grow ONLY if the
same release also names what to shrink.

```
| Field                                | This Release                                     |
|--------------------------------------|--------------------------------------------------|
| Version                              | {e.g. v9.7.0}                                    |
| Layers/skills/rules ADDED            | {list, or "none"}                                |
| Layers/skills/rules REMOVED / MERGED | {list, or "none"}                                |
| Net-layer delta                      | added − removed (target: ≤ 0 over time)          |
| DROP/MERGE candidate(s)              | {≥1 name from Layer ROI DROP/SHRINK verdicts,    |
|                                      |  or "none yet — first ablation pending"}         |
| Extend-over-add honored?             | YES/NO (extended existing layers, not new ones?) |
```

**Gate**: if ADDED is non-empty AND DROP/MERGE candidate is empty AND "first ablation pending"
is not logged → FLAG as FAILURE 21 recurrence in the evolution proposals. The human gate
decides whether the growth is justified.

**Write** `state.complexity_ratchet = { layers_added, layers_removed, net_delta,
drop_merge_candidates }`. Phase 0 of the NEXT run reads it: a standing DROP candidate should
be scheduled as the next Ablation Run.

**This release (v9.7.0) self-application** — the ratchet applied to itself:
- ADDED: 0 new failure modes / rules. Complexity Ratchet was folded INTO FAILURE 21 + Global
  Rule 22 by EXTENSION, not new counts. Net-rule delta = 0. Extend-over-add honored = YES.
- DROP/MERGE candidate named: field-mapping defense is currently 7 layers (L1–L7) for ONE
  failure mode (FAILURE 14) — flagged for MERGE to ≤3 in v9.7.1, to be validated by ablation.

**This release (v9.7.1) self-application** — the ratchet's FIRST real cut (net delta < 0):
- REMOVED / MERGED: field-mapping defense 7 layers → 3 roles. Dropped the redundant micro-loop
  LLM diff (old L6); merged the 2 declaration ROI IDs → `field_mapping_contract` and the 2 gate
  ROI IDs → `field_mapping_gate`. Canonical layer_roi **21 → 19 (net −2)**.
- ADDED: 1 deterministic grep spot-check INSIDE the existing Phase 4A gate (no new layer/ID —
  a hardening of the kept gate that absorbs old L6's only unique sub-class: fabricated evidence).
- Extend-over-add honored = YES. **First negative net-layer delta — the ratchet demonstrably works.**
- Safety: two independent field-mapping gates remain (deterministic 4A + independent 4B re-derive),
  so FAILURE 14 stays defended; ablation over the next runs confirms no escape.

### Ablation Run (v9.6 — OPTIONAL TRIGGER)

If the Layer ROI table shows ≥1 DROP-candidate, propose an ablation run for the NEXT
feature:

```
ABLATION PROPOSAL:
  Disable layer: {layer name}
  Method: set state.disabled_layer = "{name}" at INTAKE
  Risk: {predicted failure mode if drop is wrong}
  Success criterion: feature completes without that layer's failure mode triggering
  Reverse criterion: feature triggers the failure mode → restore the layer + add a
    "ablation-confirmed-need" tag to its row in Layer ROI table
```

Record in retro:
- `ablation_run.disabled_layer`: which one
- `ablation_run.result`: SUCCESS (drop confirmed) / REVERTED (layer earned back)
- `ablation_run.evidence`: which failure mode (or absence thereof) was observed

Ablation results are the ONLY admissible evidence for permanent layer removal in v9.7+.

## Memory Loop

This file is READ at next INTAKE (Phase 0) to close the loop:
**Task Completion → Retro Write → Memory File → Next Run Recall → Better Performance**
