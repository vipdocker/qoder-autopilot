<!-- version: 9.6.1 -->
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

6.5 INTENT RECOGNITION & SKILL INJECTION (v9.6.1 — ONCE per feature, here only)

   Why ONCE at intake (not per-phase):
     - Per-phase intent recognition would re-run 7-11 times per feature → token waste
     - Skill set rarely changes mid-feature; if it does, that's a re-scope signal
     - Single confirm gate is cheaper for the user than 7 mini-confirms
     - Failure mode to avoid: adding layers without measuring (FAILURE 21);
       this gate is ROI-tracked so we know whether the injection actually helped.

   Protocol:

     a. ENUMERATE the user's installed skill library:
        → Read the available-skills system-reminder injected at session start
        → Build a flat list: [{ name, description (first line), trigger_terms }, ...]
        → DO NOT load full skill bodies — descriptions only

     b. EXTRACT signal terms from the feature description + acceptance criteria:
        → tech stack (react/vue/django/flask/python/typescript/...)
        → data shape (excel/csv/pdf/word/markdown/sqlite/postgres/...)
        → domain (finance/stock/trading/research/design/marketing/...)
        → UI surface type (dashboard/landing/form/chart/report/...)
        → external service (slack/dingtalk/lark/email/...)
        → task verb (extract/render/scrape/generate/analyze/benchmark/...)

     c. PROPOSE per-agent skill candidates (skill.description must literally
        contain at least one signal term, OR appear in the agent's existing
        skills: list as a baseline). Cap at 3 per agent to control token cost.

        proposed_injection = {
          "researcher":         [ {skill, why_match}, ... ],   # 0-3
          "designer":           [ {skill, why_match}, ... ],   # 0-3
          "frontend-designer":  [ {skill, why_match}, ... ],   # 0-3 (only if has_frontend)
          "planner":            [ {skill, why_match}, ... ],   # 0-3
          "implementer":        [ {skill, why_match}, ... ],   # 0-3
          "reviewer":           [ {skill, why_match}, ... ],   # 0-3
          "finisher":           [ {skill, why_match}, ... ]    # 0-3
        }

        Skip rule: if NO signal term matches an agent's plausible domain → list = [].
        Do NOT pad with weak matches just to fill a slot. Empty list is a valid answer.

     d. HUMAN GATE — present the proposal, ask user to confirm/edit/skip:
        - Default: accept all proposals
        - User can: remove specific items, add skills not auto-detected, or skip entirely
        - Skipped agents fall back to their hard-coded `skills:` list in agent file

     e. PERSIST to state:
        state.injected_skills = { <agent_name>: [skill_name, ...] }
        state.injection_signals = { <signal_term>: [matched_skills, ...] }
        state.layer_roi.intent_injection = { fire_count: 0, blocker_catch: 0,
                                              helped_phases: [] }

     f. PROPAGATE in each Task() dispatch:
        When the orchestrator dispatches any agent, include the injected_skills
        for that agent in the assignment block as:

          Injected Skills (v9.6.1 intent-recognition):
            - skill_name_1 — reason: {why_match}
            - skill_name_2 — reason: {why_match}
          (Use these IN ADDITION to your declared skills: list. Mark "INJECTION_USED:
           {skill_name}" in your output JSON for ROI tracking.)

     g. ROI TRACKING (closed at Phase 7 retro):
        - Each agent reports back which injected skills it actually used (or not)
        - Phase 7 retro reads state.layer_roi.intent_injection:
          • fire_count = total injections proposed
          • blocker_catch = injected skills that demonstrably caught issues
                            (cited in batch_reviews findings or implementer concerns)
          • helped_phases = which phases reported "INJECTION_USED" with positive outcome
        - 3-run rolling window: if a skill is consistently injected but never marked
          INJECTION_USED → demote it from the matching signal in next run's proposal

   ⛔ NEVER inject skills without the human gate (e). Auto-injection silently
      shifts agent behavior and violates the harness-design "every layer encodes
      an assumption" principle — the human MUST see the assumption.
   ⛔ NEVER load full skill bodies during enumeration (a). Only descriptions.
      Loading a skill costs tokens whether the agent calls it or not.
   ⛔ NEVER inject the same skill into more than 2 agent roles. If a skill seems
      to belong everywhere, it's either too generic to help, or it duplicates
      an existing baseline skill.

7. HUMAN GATE: user confirms requirements + acceptance criteria
   (combined with the §6.5(d) injection-confirm gate to keep gates at 1 per phase)
8. Write state: { current_phase: "RESEARCH", feature: "...", has_frontend: ...,
   injected_skills: {...}, injection_signals: {...} }
```
