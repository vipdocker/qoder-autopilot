---
name: qoder-autopilot
description: "v9.5 多 Agent 自动开发流水线 — 从需求到发布的全流程编排。调度 7 个专业 Agent 完成研究→设计→规划→实现→评审→完成。Triggers: 'qoder-autopilot', 'qoder autopilot', '自动开发', '全自动', '一键开发', 'autopilot', 'end-to-end development', '端到端开发'."
version: 9.5.3
---

# Qoder Autopilot v9.5 — Lean Orchestrator

## Design Philosophy

```
v9.2 = v9.1 + architecture design principles (6 abstract derivable principles)
v9.3 = v9.2 + same-family sibling scan + sibling contract consistency check
v9.4 = v9.3 + cross-layer field mapping contract (backend↔frontend naming)
v9.5 = v9.4 + security audit + performance baseline + systematic debugging + health score

Core unchanged:
  Superpowers orchestration spine + gstack product judgment + cost efficiency
  Path-only dispatch, DAG execution, deployment-chain checks, state file
  No test suites — implementer/finisher self-verify (type/lint/build)
  Reviewer spec-compliance checks BOTH design_doc + frontend_spec
  Phase 5B independent verification (architecture + frontend style compliance)
  v9.0: JSON output, error classification, concurrency lock, idle timeout

v9.1 changes (Contract-Triple-Point):
  ADDED contract consistency as cross-cutting concern across ALL agents
  ADDED Researcher: Baseline Signature Scan (同族实现的接口快照)
  ADDED Designer: Explicit Contracts chapter (隐式契约升格为显式)
  ADDED Planner: Contract Consistency Test tasks in DAG (T_contract_*)
  ADDED Implementer: Peer Read-Before-Code (先读队友代码再下笔)
  ADDED Reviewer: Contract Severity Matrix (契约不一致=BLOCKER)
  ADDED Finisher: End-to-End Contract Smoke Test (端到端调用验证契约)
  NEW FAILURE 11: 同族实现契约失配 — 单测通过但集成崩溃

v9.2 changes (Architecture Design Principles):
  REPLACED specific AI/SSE recipe rules → 6 abstract derivable principles
  Principle 1: 层职责单一性 — each layer owns exactly one decision domain
  Principle 2: 协议原生性 — use platform's canonical API for each protocol
  Principle 3: 消息类型显式判别 — discriminator field required in heterogeneous streams
  Principle 4: 外部配置边界规范化 — normalize at config boundary, not at usage site
  Principle 5: 抽象层污染防范 — base class = general contract, not scenario toolbox
  Principle 6: 用户可观测完整性 — all backend state transitions must surface in UI
  NEW FAILURE 12: 架构层职责漂移（典型案例，所有具体问题均可由原则推导）

v9.3 changes (Same-Family Baseline + Contract Regression):
  ENHANCED Phase 1 Researcher: SAME-FAMILY SCAN — produce Baseline Signature Table for all
    same-layer siblings found on main/current branch. Required in research_brief.
  ENHANCED Phase 5B Verifier: SIBLING CONTRACT CONSISTENCY CHECK — find existing
    same-layer siblings, compare conventions, classify as CONSISTENT / DEVIATED.
  ENHANCED Phase 7 Evolve: two mandatory retrospective tables added to retro format:
    (1) Requirement vs Implementation Delta — trace each acceptance criterion to change_registry
    (2) Sibling Consistency Summary — populate from Phase 5B consistency_deviations result
NEW FAILURE 13: 同族实现未被发现 — Researcher 遗漏同层文件，导致命名/协议/风格不一致

v9.4 changes (Cross-Layer Field Mapping Contract):
  ENHANCED Phase 1 Researcher: API FIELD NAMING CONVENTION SCAN — investigate the project's
    backend serialization style + frontend consumption style + conversion boundary.
    Produces "API Field Naming Convention" block in research_brief.
  ENHANCED Phase 2A Designer: FIELD MAPPING CONTRACT chapter — explicit per-endpoint table
    of (backend wire field ↔ frontend consumed field ↔ type ↔ conversion point).
    Required when has_frontend AND backend API involved.
  ENHANCED Phase 2B Frontend Designer: HONOR FIELD MAPPING CONTRACT — component state shape
    and props MUST use frontend-side field names from the contract.
  ENHANCED Phase 4A Implementer: FIELD MAPPING ADHERENCE — backend serializer enforces wire
    names, frontend code reads contract names, self-checks via grep before reporting PASS.
  ENHANCED Phase 4B Reviewer: CROSS-LAYER FIELD MAPPING CHECK — builds reality table from
    actual code, compares vs contract, classifies via Cross-Layer Severity Matrix.
    Mismatches with no conversion = BLOCKER.
NEW FAILURE 14: 跨层字段名映射失配 — 后端发 snake_case，前端读 camelCase，无转换层 → undefined

v9.5 changes (Security + Performance + Systematic Debugging + Health):
  ADDED Phase 4B Reviewer: SECURITY AUDIT via /cso — OWASP Top 10 + STRIDE threat model.
    New quality gate field: security_audit (PASS/FAIL). Vulnerability = CRITICAL+ severity.
    Skill added to reviewer: cso. New mandatory proof required.
  ADDED Phase 5A Finisher: PERFORMANCE BASELINE via /benchmark — Core Web Vitals + resource
    size baseline comparison. Has_frontend=true only. Regression = HIGH (blocking).
    New scorecard field: perf_baseline. Skill added to finisher: benchmark.
  ADDED Phase 4A Implementer: SYSTEMATIC DEBUGGING via /investigate — structured root-cause
    debugging protocol replaces ad-hoc 2-attempt fix loop. Iron Law: no fix without
    investigation. Max 3 investigation cycles. Skill added to implementer: investigate.
  ADDED Phase 7 Orchestrator: HEALTH SCORE via /health — composite 0-10 code quality score
    (type-check + lint + dead-code + coverage). Trend tracking across runs. DECLINING for
    2+ consecutive runs = HIGH-priority evolution proposal.
  NEW FAILURE 15: 安全漏洞漏审 — Reviewer 无安全维度，OWASP/STRIDE 类问题到生产才被发现
  NEW FAILURE 16: 性能退化静默交付 — 无 baseline 比较，Core Web Vitals 退化未被检测

v9.5.1 changes (frontend-design relocation, part 1 — superseded by v9.5.2):
  CHANGED Phase 2B Frontend Designer: removed Skill("frontend-design") call. Skill's
    code-generation purpose conflicted with agent's spec-document deliverable, causing
    subagent hangs even with override text. Replaced with inline 6-dimension design
    thinking protocol (aesthetic/typography/color/layout/motion/components).

v9.5.2 changes (frontend-design dual-layer architecture):
  RELOCATED frontend-design skill from Phase 2B (designer) to Phase 4A (implementer).
    Rationale: skill's "produce production-grade frontend code" intent matches
    implementer's job (write code), not designer's job (write spec).
  Phase 2B keeps inline design thinking → produces SPEC document.
  Phase 4A implementer conditionally calls Skill("frontend-design") IF task.changed_files
    contains UI extensions (.tsx/.jsx/.vue/.svelte/.astro/.html/.css/.scss/.sass/.less).
    Pure backend tasks SKIP the skill — token discipline.
  Skill added to implementer: frontend-design (conditional). Mandatory skill count: 12 → 13.
  Phase 6 Checklist row 13 added: "frontend-design (gstack skill) — IF UI TASK".

v9.5.3 changes (Phase 2B inline framework upgrade — absorbing plan-design-review essence):
  EXPANDED Phase 2B inline design thinking from "6 dimensions, prose form" to a structured
    self-rating framework (without calling external skill — keeps zero-runtime-dep advantage).
  ADDED 2a: Surface Type classifier (MARKETING / APP_UI / HYBRID) — different rule sets per type.
  ADDED 2b: 0-10 self-rating per each of the 6 dimensions, with mandatory gap+fix when <8.
  ADDED 2c: Interaction State Coverage matrix (LOADING / EMPTY / ERROR / SUCCESS / PARTIAL)
    per major component — empty/error states are FEATURES, not afterthoughts.
  ADDED 2d: AI Slop Anti-Pattern Self-Check (11 patterns: purple gradient, 3-col feature grid,
    icon-circles, centered-everything, bubbly border-radius, decorative blobs, emoji bullets,
    colored left-border cards, generic hero copy, cookie-cutter rhythm, system-ui as primary).
  ADDED 2e: Hard Rejection (7 instant-fail) + Litmus Checks (7 yes/no) self-checks.
  ADDED 2f: Universal Red-Line Rules (CSS vars, no default font stacks, ≥16px body,
    ≥4.5:1 contrast, no placeholder-as-only-label, visited-link distinction, etc).
  Output Contract expanded: Surface Type, Dimension Ratings table, AI Slop / Litmus / Red-Line
    self-check results — implementer reads these as concrete acceptance criteria.
  Rationale: plan-design-review (1759 lines) provides excellent rules but is interactive,
    gstack-coupled, and runtime-incompatible with non-interactive subagents. Inline the rules,
    skip the runtime — keep stable, zero-token-overhead, self-contained design rigor.
```

---

## KNOWN FAILURE MODES (from v6.0–v9.0)

```
FAILURE 1: Agent files not used → skills never called
  FIX → Subagent MUST read its agent file. Orchestrator passes PATH, not content.

FAILURE 2: Batch review (Phase 4B) skipped → 0 code reviews
  FIX → Phase 4B MANDATORY. batch_reviews must NOT be empty before Phase 5.

FAILURE 3: Finisher skipped → code committed blind
  FIX → Phase 5 is a MANDATORY Task() dispatch.

FAILURE 4: Orchestrator Read() agent files → context compression
  FIX → Orchestrator NEVER reads agent files. Only passes PATH.

FAILURE 5: DAG missed deployment dependencies → stale cache bug
  FIX → Planner: deployment-chain check. Reviewer: static-asset audit.

FAILURE 6 (v7.0): Frontend design spec dropped from pipeline after Phase 2B → UI diverged
  FIX (v8.0) → Pass frontend_spec_path to ALL downstream agents. Global Rule 8.

FAILURE 7 (v8.0): Implementation passes spec-compliance but diverges from PROJECT REALITY
  FIX (v8.0) → Phase 5B: independent verification agent. Triple defense.

FAILURE 8 (v9.0): Orchestrator misparses agent report → advances with false PASS
  Root cause: agent returns free-text report, orchestrator LLM "interprets" status
  instead of reading a machine-parseable value. Ambiguous text = wrong gate decision.
  FIX (v9.0) → Structured JSON output. Every agent appends --- JSON --- block.
  Orchestrator parses JSON FIRST (deterministic). Fallback to text ONLY if JSON missing.

FAILURE 9 (v9.0): API rate-limit treated as code bug → wastes retries on non-code issue
  Root cause: all errors treated uniformly → retry logic burns attempts on transient errors.
  FIX (v9.0) → Three-tier error classification. FATAL=stop, TRANSIENT=wait+retry, CODE=fix+retry.

FAILURE 10 (v9.0): Parallel sessions modify same feature → merge conflicts
  Root cause: no mutual exclusion — two sessions can dispatch on same branch simultaneously.
  FIX (v9.0) → Concurrency lock in state.json. Acquire before dispatch, release on complete.

FAILURE 11 (v9.1): 同族实现契约失配 — 单测通过但跨模块集成崩溃
  Root cause: new implementation of existing family (new DAO/Service/Adapter) has different
  return types, different error handling, or different semantic conventions vs siblings.
  Unit tests pass (each module isolated) but integration fails (downstream expects uniform contract).
  Pattern: str date vs date object, None vs [] for empty, UTC vs local timezone, cents vs dollars.
  FIX (v9.1) → Contract-Triple-Point (CTP): 6-layer defense across entire pipeline.
    Layer 1: Researcher produces Baseline Signature Table (existing family's contract)
    Layer 2: Designer writes Explicit Contracts chapter (new impl MUST match)
    Layer 3: Planner adds T_contract task in DAG (dedicated verification task)
    Layer 4: Implementer does Peer Read-Before-Code (reads sibling, self-checks diff)
    Layer 5: Reviewer applies Contract Severity Matrix (mismatch = BLOCKER, not NIT)
    Layer 6: Finisher runs E2E Smoke Test (real call chain, not just unit test)

FAILURE 12 (v9.2): 架构层职责漂移 — 实现逻辑滑落到错误的层 （典型案例）
  Root cause: 开发者在“离需求最近的地方”就地实现逻辑，没有问“这个逻辑属于哪一层”。
  所见症状：多个层同时包含同一业务关心的不同片段，每次需求变更都需要弹涉多个层修改。
  本案中的所有具体问题（POST vs GET、fetch vs EventSource、
    api_base 拼接、代理缺失、stream_custom 污染基类、reasoning UI 缺失）
    均可由下方 6 条架构设计原则推导。
  FIX (v9.2) → 重构前先问：「这段逻辑的决策权属于哪一层？」
    如果能正确回答这个问题，其余所有具体选择都会自然出现。
    见下方“架构设计原则”章节。
```


FAILURE 13 (v9.3): 同族实现未被发现 — 命名/协议/风格与既有同层文件不一致
  Root cause: Researcher searches feature-domain files but does NOT find existing
  same-layer siblings (other route handlers, other service methods, other HTML Tab
  structures in the same panel). Implementer writes a self-consistent but project-
  inconsistent implementation. Only discovered via user review after completion.
  Typical symptoms: element ID naming diverges from siblings (mdAIStartBtn vs mdAiStartBtn),
  CSS class naming pattern diverges, JS function naming pattern diverges, event schema
  differs from existing handlers in the same file.
  FIX (v9.3) → Phase 1 SAME-FAMILY SCAN (mandatory):
    Step 1: identify the LAYER TYPE of what we're building (route/service/HTML tab/JS module)
    Step 2: grep the codebase for existing files/elements of that layer type
    Step 3: read siblings → produce Baseline Signature Table in research_brief
    Step 4: orchestrator VERIFIES Baseline Signature Table exists before Phase 2
    Step 5: Designer treats Baseline Signature Table as CONTRACT CONSTRAINT, not reference

FAILURE 14 (v9.4): 跨层字段名映射失配 — 后端字段名与前端读字段名不匹配，无转换层
  Root cause: 后端按语言习惯用 snake_case (Python, Go, Ruby) 输出 API JSON，前端按
  JS 习惯用 camelCase 读取，但项目里没有显式的字段转换层（Pydantic alias /
  camelizeKeys / interceptor），结果前端拿到的是 undefined。或者反向：后端输出
  camelCase 但前端按 snake_case 读取。还有更隐蔽的：项目里有 80% 的接口经过转换层，
  新写的 20% 没有，导致前端必须知道哪些接口有转换、哪些没有。
  Typical symptoms:
    - 前端 console 拿到对象但所有字段都是 undefined
    - 前端 TypeScript 接口字段命名风格混杂 (有的 user_name 有的 userName)
    - 同一个组件里既读 response.user_name 又读 response.createdAt
    - QA 截图发现卡片显示空白但数据明明有
  FIX (v9.4) → Cross-Layer Field Mapping Contract (5-layer defense):
    Layer 1: Researcher SCAN — backend output style + frontend consumption style + conversion boundary
    Layer 2: Designer CONTRACT — Field Mapping Contract chapter with per-endpoint mapping table
    Layer 3: Frontend Designer HONOR — component state/props use contract's frontend names
    Layer 4: Implementer ADHERE — serializer enforces wire names, frontend reads contract names, self-grep
    Layer 5: Reviewer CHECK — Cross-Layer Field Mapping Severity Matrix (no-conversion mismatch = BLOCKER)

FAILURE 15 (v9.5): 安全漏洞漏审 — 无安全维度导致 OWASP/STRIDE 类问题进入生产
  Root cause: Reviewer 只做规范合规 + 契约一致性检查，没有安全维度。XSS、SQL注入、
  SSRF、insecure deserialization 等 OWASP Top 10 漏洞和 STRIDE 威胁在 lint/type 层面
  无法检测，需要专门的安全审计逻辑。这些问题的共同特征是：功能层面完全正确、测试全绿、
  spec 完全符合，但攻击面已经暴露。
  Typical symptoms:
    - 功能 QA 全部通过但渗透测试第一天就发现 SQLi/XSS
    - 代码 review 关注结构和风格但从未质疑输入验证
    - 用户提交的内容直接拼接到 HTML/SQL/命令行参数
    - 新暴露的 API endpoint 没有 auth check
  FIX (v9.5) → Phase 4B Reviewer 强制调用 /cso 安全审计。
    security_audit quality gate 字段。CRITICAL 漏洞 = BLOCKING。
    Security Severity Matrix 内置于 reviewer agent。

FAILURE 16 (v9.5): 性能退化静默交付 — 无 baseline 导致 Core Web Vitals 退化不可观测
  Root cause: 前端变更后没有性能比较步骤。LCP / CLS / FID 退化、资源体积膨胀、
  未压缩的新依赖引入——这些都只在用户体验恶化后才被发现。type/lint/build 检查无法
  捕获性能退化。这是一个"所有门控都通过但用户体验持续恶化"的静默衰退模式。
  Typical symptoms:
    - 用户反馈"越来越慢"但团队说"没改什么"
    - lighthouse 分数从 90 降到 60 但没人注意
    - 新引入的 300KB 未压缩依赖通过了所有 review
    - 图片/字体未经优化直接上线
  FIX (v9.5) → Phase 5A Finisher 前端强制 /benchmark 性能基线比较。
    perf_baseline scorecard 字段。HIGH 回归 = Finish Gate FAIL。
    Performance Regression Matrix 内置于 finisher agent。
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

STEP 3 — PARSE RESULT (v9.0: JSON-first)
  a. Search agent output for "--- JSON ---" marker
  b. IF found: parse the JSON block → extract status, gate, metrics
     → This is the AUTHORITATIVE result. Ignore any contradictions in free text.
  c. IF NOT found (fallback): extract from free text as before
     → Log warning: "Agent did not produce JSON block — using text fallback"
  d. Verify skill proofs (from JSON proofs_summary or text "Skills Called:" section)
  e. ⛔ If ANY required proof missing → re-dispatch with explicit skill names

STEP 4 — RECORD IMMEDIATELY (v9.0: immediate artifact write)
  a. Update state.json IMMEDIATELY after parsing (not at end of phase):
     → dag[id].status, dag[id].proofs, change_registry[id]
     → artifacts.{key} = path (if agent produced an artifact)
     → skills_invoked += [called skills]
  b. This ensures: if context compression happens BETWEEN dispatches,
     all prior results are already persisted in state.

STEP 5 — ERROR CLASSIFICATION (v9.0: three-tier)
  IF agent reports FAIL or dispatch throws:
    CLASSIFY the error (see reference.md "Error Classification"):
      FATAL    → mark BLOCKED, surface to user immediately, do NOT retry
      TRANSIENT → wait (exponential backoff: 30s, 60s, 120s), retry same dispatch
      CODE     → fix context retry (count against convergence limit)
    Record error_class in state: dag[id].last_error = { class, message, attempt }
```

---

## CONCURRENCY LOCK PROTOCOL (v9.0)

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

## DETERMINISTIC RECOVERY PROTOCOL (v9.0)

```
⛔ If resumed after context compression OR new session on existing state:

1. Call Skill(skill="qoder-autopilot") — reload this orchestrator
2. Read("{project_root}/.autopilot-state.json") — source of truth
3. DETERMINISTIC PHASE CHECK (do NOT guess — evaluate conditions):

   Phase 0 INTAKE:    DONE if human_gates.requirements != null
   Phase 1 RESEARCH:  DONE if artifacts.research_brief != ""
   Phase 2 DESIGN:    DONE if artifacts.design_doc != "" AND human_gates.design != null
   Phase 3 PLAN:      DONE if artifacts.plan_doc != "" AND dag is populated
   Phase 4 EXECUTE:   DONE if ALL dag tasks have status "done" AND batch_reviews is non-empty
   Phase 5 FINISH:    DONE if human_gates.merge_strategy != null
   Phase 6 AUDIT:     DONE if audit_passed == true
   Phase 7 EVOLVE:    DONE if retro_saved == true

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
  "version": "9.2",
  "current_phase": "EXECUTE",
  "feature": "...",
  "has_frontend": true,
  "skills_invoked": [],
  "dag": {
    "T1": { "status": "done", "proofs": {}, "last_error": null }
  },
  "change_registry": { "T1": { "files_modified": [], "files_added": [] } },
  "batch_reviews": [],
  "artifacts": {
    "research_brief": "/path/to/brief.md",
    "design_doc": "/path/to/design.md",
    "frontend_spec": "/path/to/spec.md",
    "plan_doc": "/path/to/plan.md"
  },
  "human_gates": { "requirements": null, "design": null, "merge_strategy": null },
  "audit_passed": false,
  "retro_saved": false,
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
| 4: EXECUTE | `phases/phase-4-execute.md` | implementer ×N + reviewer | investigate (on-fail), frontend-design (IF UI files), cso, requesting-code-review, ast-code-analysis, receiving-code-review | batch_reviews non-empty |
| 5: FINISH | `phases/phase-5-finish.md` | finisher + verifier | finishing-a-development-branch, benchmark (IF FE) | Verification + Human Gate |
| 6: AUDIT | `phases/phase-6-done.md` | (main session) | — | 13-skill checklist pass |
| 7: EVOLVE | `phases/phase-7-evolve.md` | (main session) | health | retro saved |

⛔ For each phase: `Read("phases/phase-N-*.md")` BEFORE executing. The phase file is the source of truth.

For quality gates, resource limits, error classification, and convergence safeguards: `Read("reference.md")` when making gate/limit/error decisions.

---

## Agent Files & Model Tiers

```
Agent File                                          Model        Rationale
─────────────────────────────────────────────────── ──────────── ────────────────────────────
engineering-autopilot-researcher.md                 Kimi-K2.5    Search + synthesis
engineering-autopilot-designer.md                   Premium      Creative design decisions
engineering-autopilot-frontend-designer.md          Premium      UI/UX design (IF has_frontend)
engineering-autopilot-planner.md                    Premium      DAG construction, dep analysis
engineering-autopilot-implementer.md                Premium      Code generation + self-verify + /investigate
engineering-autopilot-reviewer.md                   Premium      Code review, AST + security (/cso)
engineering-autopilot-finisher.md                   Kimi-K2.6    Branch prep + /benchmark + final checks

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
Phase 4A: EXECUTE       [implementer ×N]  Implement + self-verify per task
    │                                      v9.5: /investigate on self-verify FAIL
Phase 4B: REVIEW        [reviewer]        4-skill code review per batch
    │                                      v9.5: /cso security audit added
    │                                      (repeat 4A+4B per DAG batch)
Phase 5A: FINISH        [finisher]        Branch prep + validation
    │                                      v9.5: /benchmark perf baseline (IF FE)
Phase 5B: VERIFY        [verifier Task]   Architecture + frontend style compliance
    │                                      Human Gate (with verification results)
    │
Phase 6: AUDIT          [main session]    13-skill checklist, remediation
    │
Phase 7: EVOLVE         [main session]    Retro → /health score → gbrain → .retro.md
```

**Dispatches (typical):** 6-9 (includes mandatory 5B verification).

---

## File Structure

```
~/.qoder/skills/qoder-autopilot/
├── SKILL.md                    ← this file (orchestrator spine)
├── reference.md                ← quality gates, resource limits, error classification
├── self-check-protocol.md      ← phase exit verification protocol
└── phases/
    ├── phase-0-intake.md       ← requirements + gbrain + human gate
    ├── phase-1-research.md     ← researcher dispatch
    ├── phase-2-design.md       ← designer + frontend-designer + human gate
    ├── phase-3-plan.md         ← planner dispatch + DAG
    ├── phase-4-execute.md      ← implement batches + mandatory review
    ├── phase-5-finish.md       ← finisher dispatch + human gate
    ├── phase-6-done.md         ← completion audit (4 checklists)
    └── phase-7-evolve.md       ← retro + gbrain + learning loop
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

---

## 架构设计原则 (v9.2)

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
