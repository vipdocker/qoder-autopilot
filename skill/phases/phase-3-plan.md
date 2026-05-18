# Phase 3: PLAN → Task()

AGENT: `engineering-autopilot-planner.md`
REQUIRED SKILLS: `writing-plans`, `dispatching-parallel-agents`
ASSIGNMENT: feature, design_doc path, frontend_spec path (if applicable), has_frontend, project path

```
1. DISPATCH via UNIVERSAL DISPATCH PROTOCOL:
   Agent file: ~/.qoder/agents/engineering-autopilot-planner.md
   Assignment: { feature, design_doc_path, frontend_spec_path (if has_frontend, else omit), has_frontend, project_path }
2. VERIFY: report has writing-plans proof ✓, dispatching-parallel-agents proof ✓
3. Extract: DAG, plan_doc path
4. skills_invoked += [writing-plans, dispatching-parallel-agents]
5. Write state: { current_phase: "EXECUTE", dag: {...}, artifacts.plan_doc: "..." }
```
