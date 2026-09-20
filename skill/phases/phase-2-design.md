<!-- version: 9.7.2 -->
# Phase 2: DESIGN → Task() + conditional Task() → HUMAN GATE

## Phase 2A: BRAINSTORM → Task() — ALWAYS

AGENT: `engineering-autopilot-designer.md`
REQUIRED SKILLS: `brainstorming`
ASSIGNMENT: feature, requirements, research_brief path, project path

```
1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
   Agent file: ~/.qoder/agents/qoder-autopilot/engineering-autopilot-designer.md
   Assignment: { feature, requirements, research_brief_path, project_path }
   Injected Skills (Global Rule 24): append state.injected_skills["designer"] block
   (skill + why_match per item) to the assignment; omit if empty.

   ⛔ FIELD MAPPING CONTRACT MANDATORY (v9.6 — IF has_frontend AND backend API):
   ADD to assignment:
     "If has_frontend=true AND this feature defines backend API endpoints, your design
      doc MUST include a 'Field Mapping Contract' chapter — as a LIGHTWEIGHT DECLARATION
      (≤ 12 lines, per your agent file §2c):
      - Read research_brief 'API Field Naming Convention' block to understand the
        project's canonical convention.
      - Declare: (1) convention direction (snake→camel / camel→snake / passthrough),
        (2) conversion boundary (file path / backend serializer / frontend transformer / none),
        (3) intentional exceptions (only if any).
      ⛔ Do NOT produce a per-field mapping table — the implementer (Phase 4A §1e)
        produces the grep-anchored Field Mapping Evidence Table post-implementation,
        and the 4A.5 micro-loop / 4B reviewer diffs it against this declaration.
      Without this chapter, implementer/reviewer have no contract direction to diff
      against and Failure 14 (cross-layer field mismatch → undefined) becomes likely."
2. VERIFY: report has brainstorming proof ✓
3. VERIFY: IF has_frontend=true AND backend API in scope → design doc MUST contain
   'Field Mapping Contract' chapter (direction + boundary declaration;
   per-field table NOT required — its absence is CORRECT per v9.6 §2c)
   → IF chapter missing entirely: re-dispatch designer with explicit instruction to add it
4. Extract: design_doc path
5. skills_invoked += [brainstorming]
```

## Phase 2B: FRONTEND DESIGN → Task() — IF has_frontend=true

AGENT: `engineering-autopilot-frontend-designer.md`
REQUIRED SKILLS: (none — inline design thinking protocol, no external skill call)
ASSIGNMENT: feature, requirements, design_doc path, research_brief path, project path

```
IF state.has_frontend == true:
  1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
     Agent file: ~/.qoder/agents/qoder-autopilot/engineering-autopilot-frontend-designer.md
     Assignment: { feature, requirements, design_doc_path, research_brief_path, project_path }
     Injected Skills (Global Rule 24): append state.injected_skills["frontend-designer"] block
     (skill + why_match per item) to the assignment; omit if empty.
  2. VERIFY: report has "Design Thinking: classify(2a) + 6-dim/0-10(2b) + state-matrix(2c) + slop-check(2d) + litmus(2e) + red-lines(2f)" ✓
  3. Extract: frontend_spec path
  4. skills_invoked += [frontend-design-thinking]
ELSE:
  Skip 2B. Record: "frontend-design: N/A — has_frontend=false"
```

## Phase 2 Completion — Multi-Angle Review

**gstack-inspired: review the design from multiple angles before approving.**

```
ORCHESTRATOR reviews design doc (without reading full content into context — scan summary only):
  - Engineering angle: Are there obvious missing error paths or race conditions?
  - Deployment angle: Does it touch static assets, configs, or API contracts?
  - Scope angle: Does the design exceed the MVP scope defined in Phase 0?
  → If concerns found, NOTE them when presenting to user.

HUMAN GATE: present design doc (+ frontend spec if applicable) + any concerns to user
Write state: { current_phase: "PLAN", human_gates.design: "approved" }
```
