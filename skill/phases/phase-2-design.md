<!-- version: 9.5.0 -->
# Phase 2: DESIGN → Task() + conditional Task() → HUMAN GATE

## Phase 2A: BRAINSTORM → Task() — ALWAYS

AGENT: `engineering-autopilot-designer.md`
REQUIRED SKILLS: `brainstorming`
ASSIGNMENT: feature, requirements, research_brief path, project path

```
1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
   Agent file: ~/.qoder/agents/engineering-autopilot-designer.md
   Assignment: { feature, requirements, research_brief_path, project_path }

   ⛔ FIELD MAPPING CONTRACT MANDATORY (v9.4 — IF has_frontend AND backend API):
   ADD to assignment:
     "If has_frontend=true AND this feature defines backend API endpoints, your design
      doc MUST include a 'Field Mapping Contract' chapter:
      - Read research_brief 'API Field Naming Convention' block to understand the
        project's canonical convention.
      - For each new endpoint/event, list a per-field mapping table:
        | Backend wire field | Frontend consumed field | Type | Example | Notes |
      - Declare the conversion point explicitly (backend serializer / frontend
        transformer / no conversion).
      - Any field that intentionally violates the convention must list its reason.
      Without this chapter, frontend designer/implementer have no contract to honor
      and Failure 14 (cross-layer field mismatch → undefined) becomes likely."
2. VERIFY: report has brainstorming proof ✓
3. VERIFY: IF has_frontend=true AND backend API in scope → design doc MUST contain
   'Field Mapping Contract' chapter
   → IF missing: re-dispatch designer with explicit instruction to add it
4. Extract: design_doc path
5. skills_invoked += [brainstorming]
```

## Phase 2B: FRONTEND DESIGN → Task() — IF has_frontend=true

AGENT: `engineering-autopilot-frontend-designer.md`
REQUIRED SKILLS: `frontend-design`
ASSIGNMENT: feature, requirements, design_doc path, research_brief path, project path

```
IF state.has_frontend == true:
  1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
     Agent file: ~/.qoder/agents/engineering-autopilot-frontend-designer.md
     Assignment: { feature, requirements, design_doc_path, research_brief_path, project_path }
  2. VERIFY: report has frontend-design proof ✓
  3. Extract: frontend_spec path
  4. skills_invoked += [frontend-design]
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
