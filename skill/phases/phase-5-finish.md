<!-- version: 9.5.0 -->
# Phase 5: FINISH → Task() + VERIFY → Task() → HUMAN GATE

**Three steps: 5A finisher (branch prep + static checks), 5B independent verification
(architecture + frontend style compliance), then human gate.**

## Phase 5A: FINISH → Task()

AGENT: `engineering-autopilot-finisher.md`
REQUIRED SKILLS: `finishing-a-development-branch`, `benchmark` (IF has_frontend)
ASSIGNMENT: branch name, feature, has_frontend, frontend_spec path (if has_frontend), project path, change summary from change_registry

```
1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
   Agent file: ~/.qoder/agents/engineering-autopilot-finisher.md
   Assignment: { branch_name, feature, has_frontend, frontend_spec_path (if has_frontend, else omit), project_path, change_summary }
   Additional instructions in agent file:
     - Run type checker, linter, build
     - Static asset reference audit (cache-busting versions)
     - If has_frontend: basic render check
     - Prepare branch (commits, changelog)
2. VERIFY: report has finishing-a-development-branch proof ✓
   VERIFY: IF has_frontend → benchmark proof ✓
3. Check Finish Gate: PASS/FAIL
4. skills_invoked += [finishing-a-development-branch, benchmark (if has_frontend)]
```

## ⛔ Phase 5B: INDEPENDENT VERIFICATION → Task() — MANDATORY

**Purpose: catch architecture drift and frontend style inconsistency that earlier phases missed.
The reviewer checks against SPECS; this agent checks against PROJECT REALITY.**

```
DISPATCH a general-purpose Task() with the following prompt:

⛔ MANDATORY: You are an independent verification agent. Your job is to verify that
  the implementation matches the PROJECT'S EXISTING PATTERNS — not just the design specs.

--- VERIFICATION ASSIGNMENT ---
Feature: {feature}
Project path: {project_path}
Has frontend: {has_frontend}
Change registry: {change_registry from state}
Research brief: {artifacts.research_brief}  (contains Frontend Design System section)
Frontend spec: {artifacts.frontend_spec} (if has_frontend)
--- END ---

## Your Protocol:

### A. ENGINEERING ARCHITECTURE VERIFICATION

1. Read the research brief's "Codebase Findings" and "Frontend Design System" sections
2. For each NEW file in the change registry:
   a. Read the file
   b. Find 1-2 existing SIMILAR files in the project (same type: service, component, util, etc.)
   c. Compare: naming conventions, file structure, export patterns, error handling patterns
   d. Verdict: CONSISTENT / DEVIATED (with specifics)
3. For each MODIFIED file:
   a. Verify the modifications follow the file's existing style (not introducing a new pattern)
   b. Verdict: CONSISTENT / DEVIATED
4. Check module boundaries: are new imports crossing architectural boundaries that
   existing code doesn't cross?

### B. FRONTEND STYLE VERIFICATION (IF has_frontend)

1. Read the research brief's "Frontend Design System" section:
   → Extract: css_methodology, design_tokens, reference_components
2. For each new/modified frontend file (HTML, CSS, JS with UI):
   a. Read the file
   b. Read 1-2 reference_components from the research brief (or find similar existing ones)
   c. Verify:
      - Uses the SAME CSS methodology (not mixing Tailwind with BEM, etc.)
      - Uses EXISTING design tokens (colors, spacing, fonts) — not hardcoded new values
      - DOM structure follows project patterns (class naming, nesting depth, component shape)
      - Event handling follows project conventions
   d. Verdict per file: MATCHES / DEVIATES (with specifics)
3. IF browser tool available:
   a. Open the app, navigate to the new feature
   b. Visually compare: does the new UI LOOK like it belongs in the same app?
   c. Check: consistent spacing, colors, typography, hover effects, transitions

### C. PRODUCE VERIFICATION REPORT

```
ARCHITECTURE & STYLE VERIFICATION REPORT
==========================================
Feature: {name}
Status: {PASS / FAIL}

Architecture Compliance:
  | File | Type | Verdict | Notes |
  |------|------|---------|-------|
  | ... | new/modified | CONSISTENT/DEVIATED | ... |
  
  Architecture Gate: {PASS / FAIL — any DEVIATED = FAIL}

Frontend Style Compliance (if has_frontend):
  css_methodology_match: {YES/NO — used: X, project uses: Y}
  design_tokens_reused: {YES/NO — hardcoded values found: [...]}
  dom_structure_match: {YES/NO — deviations: [...]}
  visual_consistency: {PASS/FAIL/NOT_CHECKED}
  
  Style Gate: {PASS / FAIL — any NO = FAIL}

Overall: {PASS / FAIL}
Deviations requiring fix: [{list with file + line + what's wrong + what it should be}]
```

### D. SIBLING CONTRACT CONSISTENCY CHECK (v9.3 — always run)

For each new file/class/function added in this feature, find 1-2 EXISTING SIBLINGS
(same layer type: service method / route handler / HTML component / JS module).
Compare the PUBLIC INTERFACE to verify the new code follows established patterns:

  | New Symbol | Sibling Symbol | Aspect | New | Sibling | Verdict |
  |-----------|----------------|--------|-----|---------|---------|
  | ...       | ...            | Return type / error style / naming | ... | ... | CONSISTENT / DEVIATED |

  Verdicts:
  - CONSISTENT: new code matches the established sibling pattern
  - DEVIATED: new code introduces a different convention (id naming, event format,
    function signature style, CSS class naming, error handling) vs siblings

  Consistency Gate: PASS if all CONSISTENT, FAIL if any DEVIATED.
  (Note: intentional design improvements are CONSISTENT if applied uniformly;
   random divergence is DEVIATED.)

AFTER RECEIVING REPORT:
  - If PASS → proceed to human gate
  - If FAIL → surface specific deviations to user in human gate presentation
    NOTE: do NOT auto-fix. Present findings and let user decide.
  - Record in state: verification_result: {PASS/FAIL, deviations: [...], consistency_deviations: [...]}
```

## Phase 5 Completion → HUMAN GATE

```
HUMAN GATE: Present to user:
  - Finish Gate: {5A result}
  - Performance Baseline: {5A perf_baseline result — PASS/REGRESSED/FIRST_RUN/N/A}
  - Verification: {5B result — architecture + style compliance}
  - If 5B FAIL: list specific deviations with fix suggestions
  - If perf REGRESSED(HIGH): flag specific regressions
  - Ask: "Merge strategy? (If verification/perf failed, fix first or accept?)"

Write state: { current_phase: "AUDIT", human_gates.merge_strategy: "..." }

⛔ DO NOT commit, merge, or push yourself. The finisher handles branch prep.
```
