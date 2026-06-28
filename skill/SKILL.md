---
name: qoder-autopilot
description: "v9.6 多 Agent 自动开发流水线 — 从需求到发布的全流程编排。调度 7 个专业 Agent 完成研究→设计→规划→实现→评审→完成。v9.6: 对齐 Anthropic harness-design — Phase 3B AC 协商 + Phase 4A.5 task-level micro-loop + reviewer 子产物落盘 + Layer ROI 数据采集 + harness 假设可证伪。Triggers: 'qoder-autopilot', 'qoder autopilot', '自动开发', '全自动', '一键开发', 'autopilot', 'end-to-end development', '端到端开发'。"
version: 9.6.1
---

# Qoder Autopilot v9.6 — Lean Orchestrator

> **Version history, rationale & per-version changelogs:** see `README.md` (install-time only, not loaded at runtime).
> This file is the runtime spine — protocols, gates, rules. It tells you **what to do now**, not **why we got here**.

---

## KNOWN FAILURE MODES

Each entry: short ID + 1-line root cause + FIX (runtime instruction). For historical context, typical symptoms, and per-version evolution, see README §"已知故障模式".

```
FAILURE 1: Agent files not used → skills never called.
  FIX → Subagent MUST read its agent file. Orchestrator passes PATH, not content.

FAILURE 2: Batch review (Phase 4B) skipped → 0 code reviews.
  FIX → Phase 4B MANDATORY. batch_reviews must NOT be empty before Phase 5.

FAILURE 3: Finisher skipped → code committed blind.
  FIX → Phase 5 is a MANDATORY Task() dispatch.

FAILURE 4: Orchestrator Read() agent files → context compression.
  FIX → Orchestrator NEVER reads agent files. Only passes PATH.

FAILURE 5: DAG missed deployment dependencies → stale cache bug.
  FIX → Planner: deployment-chain check. Reviewer: static-asset audit.

FAILURE 6: Frontend design spec dropped after Phase 2B → UI diverged.
  FIX → Pass frontend_spec_path to ALL downstream agents. Global Rule 8.

FAILURE 7: Implementation passes spec but diverges from PROJECT REALITY.
  FIX → Phase 5B independent verification (architecture + frontend style compliance).

FAILURE 8: Orchestrator misparses free-text agent report → false PASS.
  FIX → Structured JSON output. Parse JSON FIRST (deterministic). Text only as fallback.

FAILURE 9: API rate-limit treated as code bug → wastes retries.
  FIX → Three-tier error classification (FATAL/TRANSIENT/CODE). See reference.md.

FAILURE 10: Parallel sessions modify same feature → merge conflicts.
  FIX → Concurrency lock in state.json. Acquire before dispatch, release at complete.

FAILURE 11: 同族实现契约失配 — 单测通过但集成崩溃.
  FIX → Contract-Triple-Point 6-layer defense:
    L1 Researcher Baseline Signature Table | L2 Designer Explicit Contracts |
    L3 Planner T_contract task | L4 Implementer Peer Read-Before-Code |
    L5 Reviewer Contract Severity Matrix (mismatch=BLOCKER) |
    L6 Finisher E2E Smoke Test.

FAILURE 12: 架构层职责漂移 — 逻辑滑落到错误的层.
  FIX → Before writing logic, ask "which layer owns this decision?" not "where is convenient?".
    Apply the 6 architecture design principles below.

FAILURE 13: 同族实现未被发现 — 命名/协议/风格与既有同层文件不一致.
  FIX → Phase 1 SAME-FAMILY SCAN (mandatory): identify layer type → grep siblings →
    Baseline Signature Table in research_brief → orchestrator verifies table exists
    before Phase 2 → Designer treats it as CONTRACT CONSTRAINT.

FAILURE 14: 跨层字段名映射失配 — 后端 snake/前端 camel 无转换层 → undefined.
  FIX → Cross-Layer Field Mapping Contract (5-layer defense):
    L1 Researcher SCAN (naming convention + conversion boundary) |
    L2 Designer CONTRACT (per-endpoint mapping table) |
    L3 Frontend Designer HONOR (state/props use contract frontend names) |
    L4 Implementer ADHERE (serializer enforces wire names; grep self-check) |
    L5 Reviewer CHECK (Cross-Layer Severity Matrix; no-conversion mismatch = BLOCKER).

FAILURE 15: 安全漏洞漏审 — Reviewer 无安全维度，OWASP/STRIDE 类问题进入生产.
  FIX → Phase 4B Reviewer MUST invoke /cso. security_audit quality gate.
    CRITICAL vuln = BLOCKING. Security Severity Matrix internal to reviewer agent.

FAILURE 16: 性能退化静默交付 — 无 baseline 比较，CWV 退化未被检测.
  FIX → Phase 5A Finisher MUST invoke /benchmark when has_frontend.
    perf_baseline scorecard field. HIGH regression = Finish Gate FAIL.

FAILURE 17: dispatch 失败后盲目重试 / 静默放弃 — 无分类与渐进降级.
  FIX → UNIVERSAL RETRY PROTOCOL (below): CLASSIFY → TRANSIENT×3 backoff →
    CODE/MALFORMED corrective×2 → SHRINKAGE×1 → BLOCKED with full trace.
    Every attempt recorded in state.dag[id].attempts.

FAILURE 18: AC 含糊 → 4B 才发现，整批重做 (generator-evaluator 反馈环过晚).
  FIX → NEW Phase 3B: AC NEGOTIATION (fast Task dispatch). Reviewer reads plan_doc,
    returns ac_verifiability (YES/AMBIGUOUS/NO + missing-info). Planner corrective
    pass (max 1) before EXECUTE. Eliminates BLOCKER ambiguity at sprint start.

FAILURE 19: 跨层契约任务在 batch 末尾才发现失配 → batch 内多任务连锁返工.
  FIX → NEW Phase 4A.5: TASK-LEVEL MICRO-LOOP (conditional). For T_contract_* OR
    cross-layer field-mapping tasks: implementer dispatches thin reviewer
    (spec+contract+field_mapping only, NO cso/ast). Max 2 refine cycles in-task.
    state.dag[id].micro_loop_attempts records trace.

FAILURE 20: design 阶段 over-specify field mapping → designer 拍错下游一致传播.
  FIX → DOWNGRADE Designer §2c to direction + boundary declaration only.
    Per-endpoint reality table produced by Implementer §1e via grep
    (Field Mapping Evidence Table). Reviewer diffs declared vs implemented;
    any inconsistency = BLOCKER. Errors surface at earliest detectable layer.

FAILURE 21: 模型升级后 harness 不缩减 → 始终按"最坏模型"成本付费，无 ROI 数据砍层.
  FIX → Phase 7 LAYER ROI TABLE + HARNESS ASSUMPTION SNAPSHOT + ABLATION RUN HOOK.
    Per retro: record (fire_count, blocker_catch, model_used) per defense layer + 1 line
    "本 harness 当前假设模型做不到: {X}". 3+ runs trend → data-driven ablation,
    not intuition. See reference.md §Layer ROI Tracking / Ablation Run Protocol.

FAILURE 22: Agent/接口"返回了但无数据" — 输出格式合法、status=PASS，但关键载荷为空
  (change_registry 空、research_brief 无发现、API response 无字段、前端无 EMPTY 状态).
  FIX → "数据存在性"作为独立门控：
    (a) UNIVERSAL DISPATCH PROTOCOL 解析 JSON 后校验关键字段非空；
    (b) Phase 1/4 分别校验 research_brief / change_registry 有 actionable 内容；
    (c) Reviewer 跨层字段映射检查增加"Data Presence Check"（后端须返回数据、前端须处理空态）.

FAILURE 23: 实现与需求不一致/遗漏 — 任务跑完、lint/build 通过，但 Phase 5B 发现
  实际代码未覆盖设计文档中的 MUST/SHOULD 需求（覆盖率 < 95%），或 implementer
  虚报 covered_requirements。
  FIX → "需求可追溯"作为独立门控：
    (a) Planner §2d 产出 requirements_traceability.matrix，为每个需求分配 implementing_tasks；
    (b) Implementer 在 JSON 中输出 covered_requirements；
    (c) Phase 4A 编排器聚合覆盖率，< 95% 或 MUST 缺失 → 立即 corrective replan；
    (d) Phase 5B verifier 独立 RTV（Requirements Traceability Verification），对比代码、
        声明与实现；差异 > 5% 或 MUST 遗漏 → auto-fix loop（最多 2 轮）→ 仍失败则人工门控。
```

---

## UNIVERSAL RETRY PROTOCOL

⛔ This is a MANDATORY decision tree for ANY failed dispatch. The phase file `Read` does NOT
   replace this — it complements it. After parsing the agent result (DISPATCH STEP 3),
   if the result is missing/malformed/FAIL, enter this protocol BEFORE advancing or escalating.

```
TRIGGERS (any one):
  • Task() throws exception
  • Agent produces no output (empty stdout/stderr)
  • Output truncated (no closing JSON block, partial markdown)
  • --- JSON --- block missing or unparseable
  • JSON parses but required fields absent (status, gate, proofs_summary)
  • Agent reports status: "FAIL" with retryable error class
  • Required skill proof missing from Skills Called list
  • (v9.6.1) Implementer reports status: "BLOCKED" (CODE-class — investigate & retry
    once with more context; if still BLOCKED → escalate to batch assessment)
  • (v9.6.1) Implementer reports status: "NEEDS_CONTEXT" (NOT a failure — re-dispatch
    SAME prompt + add the requested context from `needs_context:[]`; does NOT consume
    retry budget; max 2 NEEDS_CONTEXT cycles per task before escalating)
  • (v9.6.1) Implementer reports status: "DONE_WITH_CONCERNS" → NOT a failure; advance
    to review. Pass `concerns:[]` into the batch reviewer's context so it can inspect.

═══════════════════════════════════════════════════════════════════════════════════
STEP A — CLASSIFY (always first)
═══════════════════════════════════════════════════════════════════════════════════
Apply Error Classification (reference.md). Possible classes:

  FATAL       → STOP. Mark BLOCKED. Surface to user immediately. NO retry.
                Examples: 401, 403, quota exceeded, account suspended.

  TRANSIENT   → Step B (backoff retry).
                Examples: timeout, ECONNRESET, 429, 503, no output (likely crash).

  CODE        → Step C (corrective retry).
                Examples: type error, lint fail, gate FAIL, logic bug in agent output.

  MALFORMED   → Step C (corrective retry, tagged separately for trend analysis).
                Examples: JSON block missing, required field absent, output truncated
                mid-section, status field empty, gate field empty, proofs_summary missing.

═══════════════════════════════════════════════════════════════════════════════════
STEP B — TRANSIENT RETRY (backoff, same prompt)
═══════════════════════════════════════════════════════════════════════════════════
Wait 30s → 60s → 120s. Re-dispatch the EXACT SAME prompt (no modification).
Max 3 attempts. After 3 TRANSIENT retries all fail → jump to STEP D (shrinkage).

   for attempt in 1, 2, 3:
       sleep(30 * 2^(attempt-1))
       result = Task(SAME prompt)
       if result is OK:  return SUCCESS
       reclassify; if still TRANSIENT and attempt < 3: continue
       else: break out
   if all 3 transient → STEP D

═══════════════════════════════════════════════════════════════════════════════════
STEP C — CODE/MALFORMED CORRECTIVE RETRY (prefix + same assignment)
═══════════════════════════════════════════════════════════════════════════════════
Compose corrective prefix:
   ```
   ⚠️ PREVIOUS ATTEMPT FAILED.
   Failure class: {CODE | MALFORMED}
   Specific reason: {one line — e.g., "JSON block missing", "DAG has no T_contract task",
                                       "spec_compliance field missing", "no skill proof for X"}
   Required output items missing: {list from Output Contract}
   Re-do the task. Pay special attention to producing a complete Output Contract,
   including the --- JSON --- block at the very end.
   ```
Prepend to the original assignment. Re-dispatch.
Max 2 corrective attempts. If both fail → jump to STEP D (shrinkage).

═══════════════════════════════════════════════════════════════════════════════════
STEP D — PROMPT SHRINKAGE RETRY (last resort before BLOCKED)
═══════════════════════════════════════════════════════════════════════════════════
Read the phase file's `## RETRY HINT` section. If present, apply its shrinkage rule.
If the phase has no RETRY HINT, apply default shrinkage:
   • Drop optional/auxiliary output sections (everything not in the gate-blocking checklist)
   • Drop non-essential context embedding (reference docs by path only)
   • Keep all gate-blocking deliverables intact

Re-dispatch ONCE with the shrunk prompt. If shrinkage fails → STEP E (BLOCKED).

═══════════════════════════════════════════════════════════════════════════════════
STEP E — BLOCKED (final state)
═══════════════════════════════════════════════════════════════════════════════════
   state.dag[id].status = "BLOCKED"
   state.dag[id].last_error.terminal = true
   Surface to user the COMPLETE attempts trace from state.dag[id].attempts:
     "Phase {N} BLOCKED after {n_attempts} attempts.
      Trace: [TRANSIENT×3 backoff] → [CODE corrective×2] → [SHRINKAGE×1] → all failed.
      Last error: {message}.
      Suggested action: {one-line recommendation}."
   Release concurrency lock. Stop.

═══════════════════════════════════════════════════════════════════════════════════
RECORDING (after EVERY attempt, success or fail)
═══════════════════════════════════════════════════════════════════════════════════
   state.dag[id].attempts.append({
     "n": attempt_number,
     "class": "FATAL|TRANSIENT|CODE|MALFORMED|OK",
     "action": "initial|backoff|corrective|shrinkage",
     "prompt_variant": "default|corrective|shrunk",
     "result": "OK|FAIL|TIMEOUT",
     "ts": ISO8601_now,
     "message": "{trimmed}"
   })
   Write state.json IMMEDIATELY (before next attempt or phase advance).
```

⛔ NEVER silently advance after a failed dispatch — always traverse this protocol.
⛔ NEVER skip CLASSIFY (Step A) — wrong class = wrong retry strategy = wasted attempts.
⛔ NEVER reuse the same prompt after CODE/MALFORMED — that's the definition of insanity.
⛔ NEVER hit BLOCKED without exhausting STEP D — graceful degradation comes before user escalation.

---

## UNIVERSAL DISPATCH PROTOCOL

Every agent dispatch follows these 5 steps. ZERO exceptions.

```
STEP 1 — COMPOSE THIN PROMPT (orchestrator context cost: ~200 bytes)
  prompt = """
  ⛔ MANDATORY: Read your instructions file FIRST before doing anything else.
  Instructions: Read("~/.qoder/agents/engineering-autopilot-{role}.md")
  Follow ALL instructions in that file. Call every Skill() listed in it.

  --- ASSIGNMENT ---
  {phase_data: feature, requirements, paths, etc.}
  --- END ---

  After completing, report in the Output Contract format specified in your instructions file.
  ⚠️ You MUST include the --- JSON --- block at the end of your report.
  """

  ⛔ DO NOT Read() the agent file yourself. It pollutes your context.
  ⛔ DO NOT write agent instructions inline. The file IS the instructions.

STEP 2 — DISPATCH
  Task(description="{phase}: {feature}", prompt=prompt, subagent_type="general-purpose")

STEP 3 — PARSE RESULT (JSON-first)
  a. Search agent output for "--- JSON ---" marker
  b. IF found: parse the JSON block → extract status, gate, metrics
     → This is the AUTHORITATIVE result. Ignore any contradictions in free text.
  c. IF NOT found (fallback): extract from free text as before
     → Log warning: "Agent did not produce JSON block — using text fallback"
  d. Verify skill proofs (from JSON proofs_summary or text "Skills Called:" section)
  e. ⛔ DATA PRESENCE CHECK (FAILURE 22 guard):
     After parsing, verify the result contains actionable data, not just a valid shell:
       • Implementer: files_modified + files_added MUST NOT both be empty when status=DONE
       • Researcher: brief_path exists AND brief contains non-empty findings (not just headers)
       • Reviewer: spec_score / batch_gate fields populated; sub_artifact paths non-empty
       • Any agent: if the phase's expected payload is empty → classify as MALFORMED
     IF empty → DO NOT advance. Enter UNIVERSAL RETRY PROTOCOL as MALFORMED
     with reason: "Agent returned valid JSON but no actionable data / empty payload".
  f. ⛔ If ANY required proof missing → re-dispatch with explicit skill names

STEP 4 — RECORD IMMEDIATELY (immediate artifact write)
  a. Update state.json IMMEDIATELY after parsing (not at end of phase):
     → dag[id].status, dag[id].proofs, change_registry[id]
     → artifacts.{key} = path (if agent produced an artifact)
     → skills_invoked += [called skills]
  b. This ensures: if context compression happens BETWEEN dispatches,
     all prior results are already persisted in state.

STEP 5 — ON FAILURE → ENTER UNIVERSAL RETRY PROTOCOL
  IF dispatch failed (no output / malformed / FAIL / exception):
    → DO NOT decide retry inline. Jump to "## UNIVERSAL RETRY PROTOCOL" above.
    → That protocol is the single source of truth for retry decisions across ALL phases.
    → It will: classify (FATAL/TRANSIENT/CODE/MALFORMED) → backoff or correct or shrink → BLOCKED.
    → Every attempt is recorded in state.dag[id].attempts.
```

---

## CONCURRENCY LOCK PROTOCOL

```
Before any Task() dispatch:
  1. Read state.json
  2. Check state.lock:
     IF lock.holder != null AND lock.holder != current_session_id:
       IF (now - lock.acquired_at) < lock.ttl_seconds:
         → ABORT: "Another session ({lock.holder}) is working on this feature. Wait or --force."
       ELSE:
         → Lock expired (stale). Safe to take over. Log: "Stale lock from {holder}, overriding."
  3. Acquire lock:
     state.lock = { holder: current_session_id, acquired_at: ISO8601_now, ttl_seconds: 1800 }
  4. Write state.json

On pipeline completion (Phase 6/7) or abort:
  state.lock = null
  Write state.json

⚠️ TTL = 30 minutes. If a session dies without releasing, next session can override after TTL.
⚠️ current_session_id = any unique identifier for this orchestration run (timestamp + random).
```

---

## DETERMINISTIC RECOVERY PROTOCOL

```
⛔ If resumed after context compression OR new session on existing state:

1. Call Skill(skill="qoder-autopilot") — reload this orchestrator
2. Read("{project_root}/.autopilot-state.json") — source of truth
3. DETERMINISTIC PHASE CHECK (do NOT guess — evaluate conditions):

   Phase 0 INTAKE:    DONE if human_gates.requirements != null
   Phase 1 RESEARCH:  DONE if artifacts.research_brief != ""
   Phase 2 DESIGN:    DONE if artifacts.design_doc != "" AND human_gates.design != null
   Phase 3 PLAN:      DONE if artifacts.plan_doc != "" AND dag is populated
   Phase 3B AC_NEG:   DONE if artifacts.ac_negotiation_result != "" AND result.gate == "PASS"
   Phase 4 EXECUTE:   DONE if ALL dag tasks have status "done" AND batch_reviews is non-empty
   Phase 5 FINISH:    DONE if human_gates.merge_strategy != null
   Phase 6 AUDIT:     DONE if audit_passed == true
   Phase 7 EVOLVE:    DONE if retro_saved == true AND layer_roi_recorded == true

4. First phase where condition = FALSE → that is current_phase. Resume there.
5. Acquire concurrency lock (Step 3 of lock protocol)
6. Print: "RECOVERED. Resuming at Phase {N}. Completed: [{list}]. Skills: [{list}]."

⛔ NEVER restart from Phase 0 if state shows progress.
⛔ NEVER trust your own "memory" of what phase you were in — only trust state.json fields.
```

---

## STATE FILE: {project_root}/.autopilot-state.json

Write BEFORE and AFTER every Task(). Read at start of every phase.

```json
{
  "version": "9.6.1",
  "current_phase": "EXECUTE",
  "feature": "...",
  "has_frontend": true,
  "skills_invoked": [],
  "injected_skills": {
    "researcher": [],
    "designer": [],
    "frontend-designer": [],
    "planner": [],
    "implementer": [],
    "reviewer": [],
    "finisher": []
  },
  "injection_signals": {},
  "dag": {
    "T1": {
      "status": "done",
      "proofs": {},
      "last_error": null,
      "attempts": [],
      "micro_loop_attempts": [],
      "touches_field_mapping_boundary": false
    }
  },
  "change_registry": { "T1": { "files_modified": [], "files_added": [] } },
  "batch_reviews": [],
  "artifacts": {
    "research_brief": "/path/to/brief.md",
    "design_doc": "/path/to/design.md",
    "frontend_spec": "/path/to/spec.md",
    "plan_doc": "/path/to/plan.md",
    "ac_negotiation_result": "/path/to/ac-negotiation.md"
  },
  "human_gates": { "requirements": null, "design": null, "merge_strategy": null },
  "audit_passed": false,
  "retro_saved": false,
  "layer_roi_recorded": false,
  "layer_roi": {
    "ctp_peer_read": { "fire_count": 0, "blocker_catch": 0 },
    "sibling_scan": { "fire_count": 0, "blocker_catch": 0 },
    "field_mapping": { "fire_count": 0, "blocker_catch": 0 },
    "cso_security": { "fire_count": 0, "blocker_catch": 0 },
    "benchmark_perf": { "fire_count": 0, "blocker_catch": 0 },
    "investigate": { "fire_count": 0, "blocker_catch": 0 },
    "micro_loop": { "fire_count": 0, "blocker_catch": 0 },
    "verifier_5b": { "fire_count": 0, "blocker_catch": 0 },
    "intent_injection": { "fire_count": 0, "blocker_catch": 0, "helped_phases": [] }
  },
  "harness_assumption": "model cannot reliably {X} on its own — verify next release",
  "ablation_run": false,
  "disabled_layer": null,
  "model_used": { "designer": "...", "implementer": "...", "reviewer": "..." },
  "lock": {
    "holder": "session_abc123",
    "acquired_at": "2026-05-07T14:30:00Z",
    "ttl_seconds": 1800
  }
}
```

---

## ORCHESTRATOR LOOP

**You are a DISPATCHER. You do NOT write code, review code, or run tests. You dispatch agents and verify their reports.**

At each phase: Read the phase file → execute its protocol → update state → proceed.

| Phase | Phase File | Agent | Required Skills | Key Gate |
|---|---|---|---|---|
| 0: INTAKE | `phases/phase-0-intake.md` | (main session) | — | Human Gate: requirements |
| 1: RESEARCH | `phases/phase-1-research.md` | researcher | — | research_brief exists |
| 2: DESIGN | `phases/phase-2-design.md` | designer + frontend-designer | brainstorming, frontend-design-thinking (IF FE, inline) | Human Gate: design |
| 3: PLAN | `phases/phase-3-plan.md` | planner | writing-plans, dispatching-parallel-agents | DAG + plan_doc exist |
| **3B: AC NEGOTIATE** | `phases/phase-3b-ac-negotiation.md` | reviewer (fast mode) | — | ac_negotiation PASS (zero AMBIGUOUS/NO) |
| 4: EXECUTE | `phases/phase-4-execute.md` | implementer ×N + reviewer | investigate (on-fail), frontend-design (IF UI files), cso, requesting-code-review, ast-code-analysis, receiving-code-review | batch_reviews non-empty |
| ↳ 4A.5 micro-loop | (inline in phase-4) | reviewer (thin mode) | — | spec+contract+field_mapping PASS for T_contract_* / cross-layer tasks |
| 5: FINISH | `phases/phase-5-finish.md` | finisher + verifier | finishing-a-development-branch, benchmark (IF FE) | Verification + Human Gate |
| 6: AUDIT | `phases/phase-6-done.md` | (main session) | — | 13-skill checklist pass |
| 7: EVOLVE | `phases/phase-7-evolve.md` | (main session) | health | retro saved + Layer ROI table populated |

⛔ For each phase: `Read("phases/phase-N-*.md")` BEFORE executing. The phase file is the source of truth.

For quality gates, resource limits, error classification, and convergence safeguards: `Read("reference.md")` when making gate/limit/error decisions.

---

## Agent Files & Model Tiers

```
Agent File                                          Model        Rationale
─────────────────────────────────────────────────── ──────────── ────────────────────────────
engineering-autopilot-researcher.md                 default      Search + synthesis
engineering-autopilot-designer.md                   Premium      Creative design decisions
engineering-autopilot-frontend-designer.md          Premium      UI/UX design (IF has_frontend)
engineering-autopilot-planner.md                    Premium      DAG construction, dep analysis
engineering-autopilot-implementer.md                Premium      Code generation + self-verify + /investigate
engineering-autopilot-reviewer.md                   Premium      Code review, AST + security (/cso)
engineering-autopilot-finisher.md                   default      Branch prep + /benchmark + final checks

All files in: ~/.qoder/agents/
Mirrored in: ~/.qoderwork/agents/
```

---

## Pipeline Summary

```
Phase 0: INTAKE         [main session]    Product-focused requirements + gbrain
    │
Phase 1: RESEARCH       [researcher]      Codebase + web + gbrain → Brief
    │
Phase 2A: DESIGN        [designer]        Brainstorming → Design Doc
Phase 2B: FRONTEND      [frontend-designer, conditional]  Frontend Spec
    │                                      Multi-angle review + Human Gate
Phase 3: PLAN           [planner]         DAG + deploy-chain deps → Plan
    │
Phase 3B: AC NEGOTIATE  [reviewer fast]   AC verifiability check + 1 corrective pass
    │                                      Failure 18 defense: spec-fuzziness before EXECUTE
Phase 4A: EXECUTE       [implementer ×N]  Implement + self-verify per task
    │                                      /investigate on self-verify FAIL
    │                                      4A.5 task-level micro-loop for
    │                                          T_contract_* / cross-layer tasks (max 2 cycles)
Phase 4B: REVIEW        [reviewer]        4-skill code review per batch
    │                                      /cso security audit
    │                                      per-skill sub-artifacts to
    │                                          .qoder-autopilot/reviews/{batch_id}/{skill}.md
    │                                      (repeat 4A+4B per DAG batch)
Phase 5A: FINISH        [finisher]        Branch prep + validation
    │                                      /benchmark perf baseline (IF FE)
Phase 5B: VERIFY        [verifier Task]   Architecture + frontend style compliance
    │                                      Human Gate (with verification results)
    │
Phase 6: AUDIT          [main session]    13-skill checklist, remediation
    │
Phase 7: EVOLVE         [main session]    Retro → /health score → Layer ROI →
                                          Harness Assumption Snapshot → gbrain → .retro.md
```

**Dispatches (typical):** 7-11 (includes mandatory 5B verification + 3B AC negotiation +
  optional 4A.5 micro-loops for high-risk tasks).

---

## File Structure

```
~/.qoder/skills/qoder-autopilot/
├── SKILL.md                    ← this file (orchestrator spine)
├── reference.md                ← quality gates, resource limits, error classification
├── self-check-protocol.md      ← phase exit verification protocol
└── phases/
    ├── phase-0-intake.md            ← requirements + gbrain + human gate
    ├── phase-1-research.md          ← researcher dispatch
    ├── phase-2-design.md            ← designer + frontend-designer + human gate
    ├── phase-3-plan.md              ← planner dispatch + DAG
    ├── phase-3b-ac-negotiation.md   ← AC verifiability + planner corrective pass
    ├── phase-4-execute.md           ← implement batches + 4A.5 micro-loop + mandatory review
    ├── phase-5-finish.md            ← finisher dispatch + human gate
    ├── phase-6-done.md              ← completion audit (4 checklists)
    └── phase-7-evolve.md            ← retro + Layer ROI + harness-assumption snapshot
```

---

## Global Rules

1. **Orchestrator = lean dispatcher.** Never implement, review, or test. Never Read() agent files.
2. **State file = truth.** Always read/write .autopilot-state.json.
3. **Path, not content.** Pass agent file PATH to subagent.
4. **Proof = required.** Verify skill proofs. No proof = not done.
5. **Missing proof → re-dispatch.** Never advance with gaps.
6. **Hard gates are hard.** batch_reviews non-empty. finisher done.
7. **gbrain when available.** Query at intake, save at evolve.
8. **frontend_spec propagates.** When has_frontend=true, pass frontend_spec_path to planner, implementer, reviewer, AND finisher. Omission = FAILURE 6.
9. **JSON-first parsing.** Always parse agent JSON block before interpreting free text. JSON = authoritative.
10. **Classify before retry.** Every failure gets FATAL/TRANSIENT/CODE classification before deciding action.
11. **Lock before dispatch.** Acquire concurrency lock at pipeline start. Release at pipeline end.
12. **Contract consistency is BLOCKER.** When adding 同族新实现, contract mismatch (type/semantic/exception/state) = BLOCKER severity. Never downgrade to NIT. One downstream caller = production incident.
13. **Layer drift is silent and compound.** When any new integration touches an existing layer boundary, Reviewer MUST ask: "does this logic belong to the layer it lives in?" — not "does it work?". Wrong-layer logic compounds across every future change. See "架构设计原则" section for the 6 derivable principles.
14. **Cross-layer field mapping is a contract.** When has_frontend AND backend API exists, design doc MUST contain Field Mapping Contract chapter. Backend wire names + frontend consumed names + conversion point are explicitly declared. Mismatches at runtime with no conversion layer = BLOCKER.
15. **Security audit is mandatory.** Phase 4B reviewer MUST invoke /cso. Vulnerability findings are CRITICAL+ severity. No security-blind reviews.
16. **Performance baseline before ship.** Phase 5A finisher MUST invoke /benchmark (when has_frontend). Regression against baseline = HIGH blocking. No silent perf degradation.
17. **Structured debugging on failure.** Phase 4A implementer MUST invoke /investigate when self-verify fails. Iron Law: no fix without investigation. Replaces ad-hoc retry.
18. **Health score in every retro.** Phase 7 orchestrator MUST invoke /health and record the composite score. Trend tracking across runs. DECLINING 2+ runs = HIGH-priority evolution proposal.
19. **Retry by protocol, not by instinct.** When ANY dispatch fails, traverse the UNIVERSAL RETRY PROTOCOL section — DO NOT decide retry strategy ad-hoc. Classify first (FATAL/TRANSIENT/CODE/MALFORMED), then apply the matching path (BLOCKED / backoff / corrective / shrinkage). Every attempt is recorded in state.dag[id].attempts. NEVER reuse same prompt after CODE/MALFORMED. NEVER reach BLOCKED without exhausting prompt shrinkage first.
20. **AC verifiability is a gate, not an opinion.** Phase 3B AC NEGOTIATE is MANDATORY between PLAN and EXECUTE. Reviewer (fast mode) reads plan_doc and returns per-AC verifiability (YES/AMBIGUOUS/NO + missing-info). Any AMBIGUOUS/NO → planner corrective pass (max 1) before EXECUTE starts. Skipping Phase 3B = FAILURE 18 reverts to v9.5 batch-level rework cost.
21. **Micro-loop high-risk tasks at task边界, not batch boundary.** During Phase 4A, for ANY task with id matching T_contract_* OR task.touches_field_mapping_boundary == true, the implementer MUST dispatch the thin reviewer (spec+contract+field_mapping only, NO cso/ast) immediately after self-verify. Max 2 refine cycles within the task. NEVER advance to next task in batch with an UNVERIFIED contract task. Maps to harness-design generator-evaluator pattern.
22. **Layer ROI + harness assumption snapshot in every retro.** Phase 7 retro MUST populate the Layer ROI table (per-layer fire_count, blocker_catch, model_used) AND record one line "本 harness 当前假设模型做不到: {X}". After 3 cumulative runs, the orchestrator surfaces any layer with fire_count > 0 AND blocker_catch == 0 across all 3 runs as an ABLATION CANDIDATE in the evolution proposals. NO retro without these two artifacts.
23. **Per-task model tier from planner.** (v9.6.1) For each implementer dispatch in Phase 4A, read `dag[task_id].recommended_model` (cheap/standard/premium) from plan_doc and route to the matching model tier. Missing field → default "standard" (back-compat). Auto-escalate: 2 consecutive failures on the same task → bump one tier (cheap→standard→premium) before next attempt; record `attempts[].model_used` in state.json so retro can compute cost-vs-quality ROI per tier.
24. **Intent-injection propagation.** (v9.6.1) Phase 0 §6.5 produces `state.injected_skills[<agent>]` (human-confirmed). For EVERY Task() dispatch in Phases 1–5, the orchestrator MUST append an `Injected Skills (v9.6.1 intent-recognition):` block to the assignment, listing each injected skill + `why_match` reason. Agents MUST reciprocate by reporting `injection_used: [<skill_name>, ...]` in their output JSON (empty array if none were called). Phase 7 retro reads these to populate `state.layer_roi.intent_injection`. Missing injected_skills (e.g., legacy state) → fall back silently to agent baseline `skills:` list (back-compat). NEVER inject without the Phase 0 human gate; NEVER inject the same skill into >2 agent roles.
25. **Data presence is a gate, not an assumption.** (v9.6.1) A valid status/gate/proofs block is NOT enough. Every phase's deliverable MUST be checked for empty-shell returns: research_brief with real findings, change_registry with actual files, reviewer sub-artifacts with real evidence, API payloads with at least one sample field, and frontend EMPTY/ERROR states for no-data scenarios. Empty-but-valid output = MALFORMED → retry protocol.
26. **Requirements coverage is a gate with a 95% floor.** (v9.6.1) The planner MUST produce a requirements_traceability.matrix; the implementer MUST report `covered_requirements`; the Phase 4A orchestrator MUST aggregate coverage and block advancement if MUST+SHOULD coverage < 95% or any MUST is missing; the Phase 5B verifier MUST independently re-verify RTV against actual code. Coverage gaps are not "deviations for human review" — they trigger an auto-fix loop (max 2 cycles) before the human gate. A requirement claimed but not implemented is a FALSE CLAIM and is treated as BLOCKER severity.

---

## 架构设计原则

> 适用场景：所有功能开发，尤其是跨层调用、外部集成、流式通信场景。
> 这些原则是可推导的，而非可背诵的。Reviewer 的工作是检查「原则是否被应用」，
> 而不是「具体实现是否与某个已知的正确代码相同」。

---

### 原则 1：层职责单一性

每个架构层只拥有一种决策权。当你在某一层写逻辑时，先问：
"这段逻辑的决策者是谁？" 而不是 "这里写方便吗？"

- **Routes 层**的决策权：HTTP 协议关心的事（参数提取、状态码、响应格式）。
  任何「要做什么」的逻辑都不属于 Routes。
- **Service 层**的决策权：业务逻辑、外部集成、数据编排。
  任何「如何调用外部服务」的逻辑属于 Service，而不是 Routes 或 DAO。
- **DAO 层**的决策权：数据持久化与查询，不感知业务规则。

判断方法：如果同一业务关心的逻辑散落在多个层，就是职责漂移。
修复方向：找到唯一有决策权的层，把逻辑集中在那里。

---

### 原则 2：协议原生性

对任何通信协议，优先使用平台/浏览器提供的原生 API，
而不是在更底层的 API 上手动重现协议语义。

核心问题：「平台已经为这个协议提供了什么 API？」
- 如果有原生 API，使用它。手写替代方案引入的 bug 是协议语义理解错误的结果。
- 如果没有原生 API，才考虑手动实现，并记录为技术债。

此原则对所有协议成立（HTTP、WebSocket、SSE、gRPC 等），
不仅限于当前已遇到的具体实现选择。

---

### 原则 3：消息类型显式判别

任何携带异构负载的消息流（SSE、WebSocket、队列、事件总线），
必须包含显式的类型判别字段（discriminator），不能靠字段存在性或字段值模式推断类型。

原因：字段存在性判断在消息结构演化时是脆弱的，
新增字段或字段重命名都会静默破坏接收方逻辑。
显式 type 字段是可扩展、可测试、可文档化的合约。

---

### 原则 4：外部配置边界规范化

外部服务的所有连接参数（URL、凭证、代理、超时）必须：
1. 从统一的配置源读取（config_manager / 环境变量），不散落在业务代码中。
2. 在进入业务逻辑之前完成规范化（normalize），包括格式修正、默认值填充、
   路径前缀检查等。
3. 配置边界是规范化逻辑唯一允许出现的位置。

原因：外部服务的配置格式因厂商而异，规范化在使用侧散落意味着
每个使用点都可能出现一种不同的边缘 case。集中规范化后，edge case 只需修复一次。

---

### 原则 5：抽象层污染防范

基类 / 接口表达的是通用合约，不是具体场景的工具箱。
当某个具体场景需要某种能力时，应在该场景所属的具体类内部实现，
而不是向上污染基类。

判断方法：如果一个基类方法只被一个子类或场景使用，
这个方法就不属于基类——它是对「抽象」概念的误用。
后果：基类方法数量增长，每个子类被迫继承不相关的方法；
修改一个场景时需要理解所有场景。

---

### 原则 6：用户可观测完整性

当后端过程拥有多个可观测状态时（加载中、思考中、生成中、完成、出错），
UI 必须将所有状态暴露给用户。静默丢弃后端状态变化是一种 UX bug，
不是「可选的增强」。

判断方法：列举后端会产生的所有状态转移，
然后确认 UI 中每一个状态转移都有对应的视觉反馈。
缺失一个 = 用户无法理解系统正在做什么 = 信任损耗。

---

> 以上 6 条原则不是检查清单，而是推导工具。
> 当你面对一个新集成场景时，逐条问自己：
> 「我当前的实现是否违反了这条原则？如果是，正确的实现应该长什么样？」
> 原则给你方向，具体实现由你推导得出。
