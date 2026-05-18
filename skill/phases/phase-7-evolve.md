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
5. Draft evolution proposals:
   - Skill updates (e.g., "writing-plans should include X")
   - Confidence recalibration (e.g., "CRUD harder than expected")
   - Model tier adjustments
   - DAG pattern insights (e.g., "frontend tasks block integration")
   - Research gaps (e.g., "should have researched X before design")
   - Self-audit insights (e.g., "I consistently skip skill X")
   - Context compression lessons (e.g., "session ran out of context at Phase 4")
6. HUMAN GATE: Present proposals, apply on approval
7. Write PERSISTENT MEMORY to .qoder-autopilot-retro.md (project root)
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
```

## Memory Loop

This file is READ at next INTAKE (Phase 0) to close the loop:
**Task Completion → Retro Write → Memory File → Next Run Recall → Better Performance**
