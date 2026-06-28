<!-- version: 9.5.0 -->
# Phase 1: RESEARCH → Task()

AGENT: `engineering-autopilot-researcher.md`
REQUIRED SKILLS: (none — uses Grep/Read/WebSearch tools)
ASSIGNMENT: feature, requirements, acceptance criteria, has_frontend, project path

```
1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
   Agent file: ~/.qoder/agents/engineering-autopilot-researcher.md
   Assignment: { feature, requirements, acceptance_criteria, has_frontend, project_path }
   IF has_frontend=true, ADD to assignment:
     "⛔ FRONTEND RESEARCH PRIORITY: This feature has frontend. You MUST investigate the
      project's existing frontend design system — CSS methodology, design tokens, existing
      component patterns, naming conventions. See your Protocol step 2 for details.
      Without this, the frontend designer will produce specs that diverge from the project."
   Additional: "If gbrain MCP is available, also query gbrain for prior knowledge
   on this feature domain using mcp__gbrain__query."

   ⛔ SAME-FAMILY SCAN MANDATORY (CTP Layer 1 — v9.3+):
   ADD to assignment:
     "Before designing anything, grep the codebase for existing files of the SAME LAYER TYPE
      as what we plan to build (e.g., if building a new AI route, find other *_routes.py;
      if building a new service method, find sibling service files; if building a new Tab
      in an HTML panel, find the other Tab HTML structures in the same file).
      For each SAME-FAMILY file/element found, read it and produce a Baseline Signature Table:

      | File | Method/Function | Signature | Return Type | Error Style | Key Semantics |
      |------|----------------|-----------|-------------|-------------|---------------|
      | ...  | ...             | ...       | ...         | ...         | ...           |

      ⛔ This table is REQUIRED in the research brief output.
      Without it, the Designer produces contracts that diverge from existing siblings.
      Diverged contracts cause Failure 11 (integration crash after unit tests pass)."

   ⛔ API FIELD NAMING CONVENTION SCAN MANDATORY (v9.4 — IF has_frontend AND backend API):
   ADD to assignment:
     "If this feature involves data flowing from backend to frontend (REST endpoint,
      WebSocket message, SSE event consumed by UI), you MUST scan the project's
      existing field naming convention:

      a. Backend serialization style — grep for Pydantic Field(alias=), DRF source=,
         struct json:\"...\" tags, @JsonProperty, naming-strategy config.
         Determine: are response fields snake_case, camelCase, or mixed?

      b. Frontend consumption style — find 2-3 existing fetch/axios/useQuery calls.
         Determine: do they read response.snake_case or response.camelCase?
         Is there a transformation layer (humps.camelizeKeys, axios interceptor,
         api/client.ts wrapper)?

      c. Conversion boundary — locate WHO does the snake↔camel conversion (or note
         that no conversion exists, which is itself a finding).

      Produce 'API Field Naming Convention' block in research_brief with fields:
      backend_output_style, frontend_consumption_style, conversion_boundary, examples,
      violations_found.

      ⛔ This block is REQUIRED in the research brief when has_frontend=true AND
      the feature touches backend API. Without it, designer cannot produce a valid
      Field Mapping Contract → undefined errors at runtime (Failure 14)."

2. Extract: research_brief path from RESEARCH BRIEF report
3. VERIFY (DATA PRESENCE — FAILURE 22 guard):
   Read the saved research_brief and confirm it contains actionable findings:
     • Codebase Findings section has at least 1 concrete, feature-relevant bullet
       (not just "I looked at the code" or empty headers)
     • IF has_frontend=true → Frontend Design System has css_methodology + at least
       1 reference_component with concrete notes
     • IF same-family files exist → Baseline Signature Table has at least 1 row
     • IF has_frontend=true AND backend API touched → API Field Naming Convention block
       has backend_output_style, frontend_consumption_style, conversion_boundary, examples
   IF any required block is empty-shell → classify as MALFORMED and re-dispatch
   researcher with explicit instruction to fill that section with concrete evidence.
4. VERIFY: IF same-family files exist → research_brief MUST contain 'Baseline Signature Table'
   → IF missing: re-dispatch researcher with explicit instruction to add the table
5. VERIFY: IF has_frontend=true AND backend API touched → research_brief MUST contain
   'API Field Naming Convention' block
   → IF missing: re-dispatch researcher with explicit instruction to add the block
6. Write state: { current_phase: "DESIGN", artifacts.research_brief: "{path}" }
```
