# Phase 0: INTAKE (main session)

**gstack-inspired: structured product intake, not just "collect requirements".**

```
1. Check .autopilot-state.json → if exists, offer resume
2. Check .qoder-autopilot-retro.md → recall insights from past runs
3. Query gbrain (if available): search for prior knowledge on similar features
   → mcp__gbrain__query with feature keywords
   → Summarize relevant findings for context
4. Collect: What, Where, Constraints
5. Product Clarity Check (gstack /office-hours inspired):
   - Who specifically needs this? (user persona)
   - What's the current workaround? (status quo)
   - What does "done" look like? (acceptance criteria)
   - What's the narrowest useful version? (MVP scope)
   → If user's requirements are vague on any point, ASK before proceeding.
6. Detect: has_frontend? (UI, pages, CSS, client JS, data display)
7. HUMAN GATE: user confirms requirements + acceptance criteria
8. Write state: { current_phase: "RESEARCH", feature: "...", has_frontend: ... }
```
