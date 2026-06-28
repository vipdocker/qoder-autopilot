# Qoder Autopilot v9.6 — 安装指南

## 概述

Qoder Autopilot 是一个多 Agent 编排技能，驱动完整的 superpowers 开发流水线。v9.6 在 v9.5 的基础上吸收 Anthropic 工程博客 [Harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) 的核心方法论：**Sprint Contract Negotiation（Phase 3B）**、**任务级 micro-loop（Phase 4A.5）**、**Per-Skill 子产物落盘**、**Calibration Anchors 抗自评漂移**、**Layer ROI + Ablation Run 证据驱动裁层**。这些机制把"流水线单向加层"扭转为"可观测、可证据化裁剪"，同时把 Field Mapping Contract 的过度规约从设计阶段下沉到实现阶段的 grep-anchored Evidence Table。调度 7 个专业 Agent，覆盖调研、设计、规划、AC 验签、实现、micro-loop、代码审查、收尾和独立验证。

### 四类正交的质量维度

| 维度 | 代际 | 描述 | 典型 bug |
|------|------|------|----------|
| 横向 · 代码层 | v9.1 CTP | 同层兄弟实现接口签名一致 | str vs date 类型契约失配 |
| 横向 · UI 层 | v9.3 Sibling Scan | 同容器 HTML/JS/CSS 命名一致 | mdAIStartBtn vs mdAiStartBtn |
| 纵向 · 跨层 | v9.4 Field Mapping | 后端↔前端字段名稳定映射 | user_name vs userName 无转换 → undefined |
| **安全+性能+质效** | **v9.5 gstack 补强** | **安全审计 + 性能基线 + 系统排错 + 健康度** | **XSS 漏审 / LCP 退化 / ad-hoc 排错失败** |
| **harness 自反馈** | **v9.6 Anthropic 对齐** | **AC 验签 + 任务级 micro-loop + 自评校准 + Layer ROI/Ablation 证据驱动裁层** | **AC 含糊到 Phase 4 才暴露 / 跨层任务失败级联整批 / 自评分通胀 / 流水线单向加层无证据** |

### 架构

```
编排器 (SKILL.md 精简脊柱, 在主会话运行)
│
│  通过 Task() + 路径传递协议调度 Agent
│  编排器保持轻量 —— 永远不读取 Agent 文件内容到自己的上下文
│  Phase 详情按需加载（渐进式加载，减少 token 消耗）
│  v9.0: 结构化 JSON 解析 + 三级错误分类 + 并发锁
│  v9.1: 契约一致性 CTP（6 层防御 同族实现契约失配）
│  v9.2: 架构设计原则（6 条可推导规则 防止层职责漂移）
│  v9.3: Same-Family Sibling Scan（UI 命名基线 + 兄弟一致性检查）
│  v9.4: Cross-Layer Field Mapping Contract（5 层防御 跨层字段映射）
│  v9.5: gstack 4 技能集成（安全 + 性能 + 排错 + 健康度）
│  v9.6: Anthropic harness-design 对齐（AC 验签 + micro-loop + sub-artifact + Layer ROI/Ablation）
│
├── Phase 0: 需求收集 ─────── 主会话（产品化需求收集 + gbrain 查询）
├── Phase 1: 调研 ────────── Task() → researcher [Kimi-K2.5]
│                              ├── 前端设计体系 + 同族签名快照 + UI 命名基线（v9.3）
│                              └── §4 API Field Naming Convention Scan（v9.4）
├── Phase 2A: 设计 ───────── Task() → designer [Premium]
│                              ├── §2b Explicit Contracts（v9.1 CTP）
│                              └── §2c Field Mapping Contract Chapter（v9.6 改为 ≤12 行方向声明：约定+转换边界+例外；不再做每字段表）
├── Phase 2B: 前端设计 ────── Task() → frontend-designer（若有前端）[Premium]
│                              ├── 读取项目现有组件 + 显式契约章节 + 多角度评审 + 人工确认
│                              └── §2b Honor Field Mapping Contract（v9.4，引用 calibration anchors v9.6）
├── Phase 3: 规划 ────────── Task() → planner [Premium]
│                              ├── DAG + T_contract_* + 前端规范对齐
│                              └── §2d touches_field_mapping_boundary 逐任务标签（v9.6，驱动 4A.5）
├── Phase 3B: AC 验签 ───── Task() → reviewer [Premium, mode=ac_negotiation] （v9.6）
│                              ├── 逐 AC 评 CLEAR/AMBIGUOUS/UNCOVERED/CONTRADICTORY
│                              └── 任一非 CLEAR → planner §2e 单次 corrective replan，否则进 Phase 4
├── Phase 4A: 实现 ───────── Task() × N → implementer（按任务）[Premium]
│                              ├── Peer Read-Before-Code + 交叉检查项目现有组件
│                              ├── §1e Field Mapping Evidence Table（v9.6 grep-anchored 证据表，下沉自 designer）
│                              ├── §1g Corrective-Findings Loop Handler（v9.6 处理 4A.5 micro-loop 回灌）
│                              └── §3b /investigate 系统化排错（v9.5，self-verify FAIL 时强制）
├── Phase 4A.5: micro-loop ─ Task() → reviewer [Premium, mode=micro_loop] （v9.6，条件触发）
│                              ├── 触发条件：T_contract_* 或 touches_field_mapping_boundary=true
│                              ├── THIN MODE 3 检查（单任务 spec + 字段映射 diff + sibling 签名）
│                              └── PASS / REFINE_REQUIRED（最多 2 轮）/ FAIL
├── Phase 4B: 审查 ───────── Task() → reviewer [Premium, mode=batch_full]
│                              ├── spec合规 + Contract Matrix + UI Naming Consistency
│                              ├── Cross-Layer Field Mapping Check + 6 行严重度矩阵（v9.4）
│                              ├── §5 /cso 安全审计 + Security Severity Matrix（v9.5）
│                              └── Per-Skill Sub-Artifact（v9.6，证据写 batch-N-*.md，主报告精简）
├── Phase 5A: 收尾 ───────── Task() → finisher [Kimi-K2.6]
│                              ├── type/lint/build + E2E smoke + 分支整理
│                              └── §3c /benchmark 性能基线（v9.5，前端时强制）
├── Phase 5B: 独立验证 ────── Task() → verifier
│                              └── 架构合规 + 前端风格合规 + Sibling Consistency Check
│                              └── 人工确认（展示 5A + 5B 结果）
├── Phase 6: 审计 ────────── 主会话（13 技能清单 + 补救 + Checklist E：AC/micro-loop/sub-artifact/ROI/snapshot/ablation）
└── Phase 7: 进化 ────────── 主会话（复盘 + 两张强制表格 + /health 健康分 + Layer ROI 表 + Harness Assumption Snapshot + 可选 Ablation Run + gbrain → .retro.md）
```

典型调度次数：7-11（含 Phase 3B AC 验签、必须的 5B 验证；4A.5 micro-loop 仅当 T_contract_*/跨层任务触发）。

### 安装路径

```
Skill (主目录):  ~/.agents/skills/qoder-autopilot/     (12 files, v9.6 新增 phase-3b-ac-negotiation.md)
Skill (软链接): ~/.qoderwork/skills/qoder-autopilot → 主目录
Agents:         ~/.qoder/agents/                       (7 files)
Agents (镜像):  ~/.qoderwork/agents/                   (7 files)
```

### 13 个必选技能

> 以下技能分别来自 **superpowers**、**gstack**、**prompts.chat** 三个上游项目，安装本 skill 之前必须先完成它们的安装。详见下文 [依赖项](#依赖项--dependencies) 章节。

| # | 技能 | 来源 | 阶段 | Agent | 条件 |
|---|------|------|------|-------|------|
| 1 | brainstorming | superpowers | 设计 | designer | ALWAYS |
| 2 | frontend-design-thinking | (内联) | 设计 | frontend-designer | IF FRONT |
| 3 | writing-plans | superpowers | 规划 | planner | ALWAYS |
| 4 | dispatching-parallel-agents | superpowers | 规划 | planner | ALWAYS |
| 5 | requesting-code-review | superpowers | 审查 | reviewer | ALWAYS |
| 6 | ast-code-analysis-superpower | prompts.chat | 审查 | reviewer | ALWAYS |
| 7 | receiving-code-review | superpowers | 审查 | reviewer | ALWAYS |
| 8 | cso | gstack | 审查 | reviewer | ALWAYS |
| 9 | finishing-a-development-branch | superpowers | 收尾 | finisher | ALWAYS |
| 10 | benchmark | gstack | 收尾 | finisher | IF FRONT |
| 11 | investigate | gstack | 实现 | implementer | IF FAIL |
| 12 | health | gstack | 进化 | (主会话) | ALWAYS |
| 13 | frontend-design | gstack | 实现 | implementer | IF UI TASK |

> **v9.5.2 架构调整**：`frontend-design` skill 从 Phase 2B（designer）移到 Phase 4A（implementer），仅当 DAG 任务涉及 UI 文件时按需加载。Phase 2B 改用内联设计思维生成 spec 文档。这样 skill 的"产出代码"本意与 implementer 的"写代码"职责完美对齐，避免了 designer 阶段的指令冲突。
>
> **v9.5.3 内联框架升级**：Phase 2B 内联设计思维从"6 维度+文字描述"扩展为结构化自评审框架——吸收 gstack `plan-design-review` 的精华规则（**不**调用该 skill，避免其 1759 行 bash 前置和交互式 STOP 点对子代理的不兼容）。具体新增：surface 分类（MARKETING/APP_UI/HYBRID）、6 维度 0-10 自评分（<8 必须列出差距+修复方案）、交互状态矩阵（LOADING/EMPTY/ERROR/SUCCESS/PARTIAL）、AI Slop 反模式 11 项自检、Hard Rejection 7 项+ Litmus 7 项问答、Universal Red-Line 9 项硬约束。这套框架完全文本化、零 runtime 依赖，子代理可机器化执行；implementer 在 Phase 4A 读到这些自检结果作为可验证的实现验收标准。
>
> **v9.5.4 Dispatch 重试与自我修正协议**：每个 dispatch 失败后，orchestrator 不再依赖"是否记得 STEP 5"靠直觉重试，而是必须走 SKILL.md 新增的 `UNIVERSAL RETRY PROTOCOL` 决策树：CLASSIFY（FATAL / TRANSIENT / CODE / **MALFORMED**）→ TRANSIENT 指数退避×3 → CODE/MALFORMED corrective prefix×2 → PROMPT SHRINKAGE×1 → BLOCKED。新增 MALFORMED 错误类（JSON 缺失、字段缺失、输出截断），与 CODE 区分但走相同 corrective 路径。每个 phase 文件可声明 `## RETRY HINT` 段落定义自己的 shrinkage 策略。Phase 3 PLAN 的 RETRY HINT：缩减时砍掉 baseline signature 表内嵌、per-task AC 枚举、规划 rationale 散文，只保留 DAG 拓扑（节点 + depends_on + T_contract_*）这一不可压缩核心；签名核对自动落到 implementer（Phase 4A 已通过 CTP Layer 4 "Peer Read-Before-Code" 读 research_brief）。state.json 新增 `dag[id].attempts` 字段记录每次重试的 class/action/prompt_variant/result，BLOCKED 时呈现完整 trace 给用户。新增 FAILURE 17 + Global Rule 19。

### 模型分级

| 模型 | Agent | 理由 |
|------|-------|------|
| Premium（默认） | designer, frontend-designer, planner, implementer, reviewer | 创意设计、代码生成、复杂分析 |
| Kimi-K2.5 | researcher | 搜索 + 综合，无需代码创建 |
| Kimi-K2.6 | finisher | 分支整理 + 检查清单验证 |

升级策略：非 Premium agent 在同一任务上失败两次 → 自动升级到 Premium 重试。

---

## 包内容

```
qoder-autopilot-package/
├── install.sh                 ← 安装脚本（运行这个）
├── uninstall.sh               ← 卸载脚本
├── README.md                  ← 本文件
├── skill/                     ← 技能文件（→ ~/.agents/skills/ + symlink）
│   ├── SKILL.md               ← v9.6 编排器精简脊柱（主入口；新增 FAILURE 18-22 + Global Rules 20-25 + Phase 3B/4A.5 调度）
│   ├── reference.md           ← 质量门、错误分类、契约一致性、资源限制；v9.6 新增 Calibration Anchors / Layer ROI / Ablation Protocol
│   ├── self-check-protocol.md ← 阶段退出验证协议
│   └── phases/                ← Phase 详情（按需加载）
│       ├── phase-0-intake.md
│       ├── phase-1-research.md       ← v9.3: SAME-FAMILY SCAN, v9.4: API FIELD NAMING SCAN
│       ├── phase-2-design.md         ← v9.4: FIELD MAPPING CONTRACT mandatory（v9.6 改为方向声明，≤12 行）
│       ├── phase-3-plan.md           ← v9.6: 链接到 phase-3b，state 转 AC_NEGOTIATION
│       ├── phase-3b-ac-negotiation.md ← v9.6 新增：sprint contract negotiation（reviewer fast-mode + planner corrective replan）
│       ├── phase-4-execute.md        ← v9.6 重写：4A → 4A.5 micro-loop（条件）→ 4B batch_full + sub-artifact
│       ├── phase-5-finish.md         ← v9.3: Sibling Consistency Check
│       ├── phase-6-done.md           ← v9.6: 新增 Checklist E（9 行）覆盖 3B/4A.5/sub-artifact/ROI/snapshot/ablation
│       └── phase-7-evolve.md         ← v9.3: 两张强制复盘表格；v9.6 新增 5 段（AC summary / micro-loop summary / Layer ROI table / Harness Assumption Snapshot / Ablation Run）
└── agents/                    ← Agent 文件（→ ~/.qoder/agents/ + ~/.qoderwork/agents/）
    ├── engineering-autopilot-researcher.md         ← v9.3 Mode B + v9.4 §4 API naming scan
    ├── engineering-autopilot-designer.md           ← v9.4 §2c → v9.6 §2c 重写为方向声明（≤12 行，禁止 per-field 表）
    ├── engineering-autopilot-frontend-designer.md  ← v9.4 §2b Honor Field Mapping Contract（v9.6 calibration anchors）
    ├── engineering-autopilot-planner.md            ← v9.6 §2d per-task tagging + §2e corrective replan
    ├── engineering-autopilot-implementer.md        ← v9.4 §1e → v9.6 §1e 升级为 grep-anchored Evidence Table + §1g Corrective-Findings Loop Handler
    ├── engineering-autopilot-reviewer.md           ← v9.4 Cross-Layer + v9.5 §5 /cso + v9.6 三模式（batch_full / micro_loop / ac_negotiation） + Per-Skill Sub-Artifact
    └── engineering-autopilot-finisher.md           ← v9.5 §3c /benchmark
```

---

## 依赖项 / Dependencies

`qoder-autopilot` **不是一个独立 skill**——它是一个调度多个上游 skill 的编排器（pipeline orchestrator）。运行流水线时，7 个 Agent 会通过 Skill tool 调用以下技能。**安装本 skill 之前，必须先安装并验证 superpowers、gstack、prompts.chat 三个上游项目。**

### 上游项目

| 项目 | GitHub | 用途 | 提供的必选 skill |
|------|--------|------|----------------|
| **superpowers** | [obra/superpowers](https://github.com/obra/superpowers) | Claude Code 的 skill 框架 + 软件开发方法论。提供大部分核心流水线技能 | 6：brainstorming · writing-plans · dispatching-parallel-agents · requesting-code-review · receiving-code-review · finishing-a-development-branch |
| **gstack** | [garrytan/gstack](https://github.com/garrytan/gstack) | Garry Tan 的 Claude Code 配置集合（43+ skills）。提供设计/安全/性能/排错/健康类技能 | 5：frontend-design · cso · benchmark · investigate · health |
| **prompts.chat** | 站点：[prompts.chat](https://prompts.chat) · 仓库：[f/prompts.chat](https://github.com/f/prompts.chat) | Fatih Kadir Akın 维护的开源 prompt 库（前身：awesome-chatgpt-prompts）。提供 AST 级代码静态分析的 prompt template | 1：[ast-code-analysis-superpower](https://prompts.chat/prompts/cmjmk2f8i000bld04ikqh7i78_ast-code-analysis-superpower) |

### 必选 skill（13 个，分布在三个上游 + 内联）

来源详见上文 [13 个必选技能](#13-个必选技能) 表。

- 来自 **superpowers**（6 个）：`brainstorming` · `writing-plans` · `dispatching-parallel-agents` · `requesting-code-review` · `receiving-code-review` · `finishing-a-development-branch`
- 来自 **gstack**（5 个）：`frontend-design` · `cso` · `benchmark` · `investigate` · `health`
- 来自 **prompts.chat**（1 个）：`ast-code-analysis-superpower`
- **内联**（1 个）：`frontend-design-thinking`（v9.5.1 起内联于 frontend-designer agent，产出 spec 文档；v9.5.3 升级为结构化 0-10 自评审框架 + AI Slop 11 项自检 + Litmus 7 项 + Red-Line 9 项硬约束；不与 gstack frontend-design skill 冲突）

任一外部 skill 缺失都会导致对应 Phase 的 Agent 调用失败。frontend-design-thinking 为内联，无需安装。

### 可选依赖

| 依赖 | 来源 | 用途 |
|------|------|------|
| `agent-browser` | gstack（[garrytan/gstack](https://github.com/garrytan/gstack)） | finisher 前端冒烟测试 + Phase 5B verifier 视觉检查 |
| `gbrain` MCP | 独立仓库 [garrytan/gbrain](https://github.com/garrytan/gbrain)；通过 gstack 的 `setup-gbrain` skill 完成 MCP 注册（参考 [USING_GBRAIN_WITH_GSTACK.md](https://github.com/garrytan/gstack/blob/main/USING_GBRAIN_WITH_GSTACK.md)） | Phase 0 需求收集时查询历史决策、Phase 7 进化阶段把复盘写入知识库 |

> **gbrain 与 gstack 的关系**：gbrain 是 Garry Tan 的"opinionated agent brain"——一个 MCP server，用作 Claude Code/Cursor/Windsurf 等客户端的长期记忆与决策库。它是独立项目（`garrytan/gbrain`），但通常通过 gstack 内的 `setup-gbrain` skill 来一键安装并注册到 Claude Code。如果你已经按上文安装了 gstack，可直接运行 `setup-gbrain` skill 完成接入。

未配置时降级处理：finisher 跳过冒烟、verifier 仅做静态比对；Phase 0 / Phase 7 跳过 gbrain 调用，复盘只生成本地 `.retro.md`。

### 安装上游依赖

```bash
# 1. 安装 superpowers（参考其 README）
git clone https://github.com/obra/superpowers.git
cd superpowers && bash install.sh   # 或按其 README 指引

# 2. 安装 gstack（参考其 README）
git clone https://github.com/garrytan/gstack.git
cd gstack && bash install.sh        # 或按其 README 指引

# 3. 从 prompts.chat 获取 ast-code-analysis-superpower
#    具体 prompt 页面：
#    https://prompts.chat/prompts/cmjmk2f8i000bld04ikqh7i78_ast-code-analysis-superpower
#    把页面上的 prompt 内容按你的 skill 目录约定落到：
#    ~/.claude/skills/ast-code-analysis-superpower/SKILL.md
#    （仓库镜像：https://github.com/f/prompts.chat）

# 4. 验证关键 skill 已安装到本机 skills 目录
ls ~/.claude/skills/brainstorming ~/.claude/skills/frontend-design \
   ~/.claude/skills/writing-plans ~/.claude/skills/finishing-a-development-branch \
   ~/.claude/skills/ast-code-analysis-superpower
# 或对应的 ~/.agents/skills/、~/.qoderwork/skills/ 路径
```

> **平台兼容性说明**：本 skill 支持 Claude Code、Qoder、QoderWork 三种宿主。安装路径会自动同步到 `~/.claude/skills/`、`~/.agents/skills/`、`~/.qoderwork/skills/`（详见下文 [安装路径](#安装路径)）。superpowers 与 gstack 的 skill 也需要确保在对应宿主可见。

---

## 安装

### 前置条件

✅ 已完成上文 [依赖项](#依赖项--dependencies) 章节中 superpowers + gstack + prompts.chat 的安装与验证。

如需快速核对所需 skill 是否齐全：

| 必选 skill | 验证 |
|------------|------|
| brainstorming, writing-plans, dispatching-parallel-agents | 来自 superpowers |
| requesting-code-review, receiving-code-review, finishing-a-development-branch | 来自 superpowers |
| frontend-design, cso, benchmark, investigate, health | 来自 gstack |
| ast-code-analysis-superpower | 来自 prompts.chat |

### 快速安装

```bash
cd qoder-autopilot-package
bash install.sh
```

脚本会：
1. 安装 skill 到 `~/.agents/skills/qoder-autopilot/`（12 文件，含 v9.6 新增的 `phase-3b-ac-negotiation.md`）
2. 创建软链接 `~/.qoderwork/skills/qoder-autopilot` → 主目录
3. 安装 agents 到 `~/.qoder/agents/` + `~/.qoderwork/agents/`（各 7 文件）
4. 自动清理旧版遗留（validator agent、~/.qoder/skills/ 旧路径）
5. 验证文件数量

### 卸载

```bash
bash uninstall.sh
```

---

## v9.5 → v9.6 变化

| 方面 | v9.5 | v9.6 |
|------|------|------|
| Sprint contract negotiation | 无 | + Phase 3B AC 验签（reviewer fast-mode 评每条 AC：CLEAR/AMBIGUOUS/UNCOVERED/CONTRADICTORY） |
| AC 不清晰处理 | 到 Phase 4 才暴露 | planner §2e single corrective replan（最多 1 次，否则 BLOCKED） |
| 任务级反馈环 | 仅 batch 边界（Phase 4B） | + Phase 4A.5 micro-loop（条件触发：T_contract_* 或 touches_field_mapping_boundary）；THIN MODE 3 检查；最多 2 次 refine |
| Field Mapping 责任分工 | designer 在设计阶段产 per-field 4 列表（over-specify 风险） | 拆分：designer §2c 改为 ≤12 行方向声明（约定+边界+例外）；implementer §1e 产 grep-anchored Evidence Table；reviewer diff |
| Implementer 失败回灌 | 无 | + §1g Corrective-Findings Loop Handler（处理 4A.5 micro-loop 回灌） |
| Planner 任务标签 | 仅 depends_on + estimated_files | + §2d touches_field_mapping_boundary 逐任务布尔 + dag_tagging_summary |
| Reviewer 模式 | 单一 batch_full | + micro_loop（THIN）+ ac_negotiation（FAST），mode 字段路由 |
| 自评分校准 | 散文 0-10 分（leniency drift） | + Calibration Anchors（每维度给 2/5/8 锚定例 + 10 分保留 + 重校准规则） |
| Reviewer 证据落盘 | 全部塞主报告 | + Per-Skill Sub-Artifact 协议（`review_artifact_dir/batch-N-*.md`），主报告精简引用 |
| Layer 删减依据 | 经验直觉 | + Layer ROI 表（14 行 × 3 run 滚动窗口，KEEP/SHRINK/DROP 判定）+ Ablation Run 协议（唯一可信删层证据） |
| 模型/环境漂移监测 | 无 | + Harness Assumption Snapshot（运行假设快照，便于跨期复盘） |
| Phase 6 审计清单 | A/B/C/D | + Checklist E（9 行：3B 结果、corrective replan、DAG tagging、4A.5 覆盖率、§1e Evidence、sub-artifact、ROI、snapshot、ablation） |
| FAILURE MODES | 16 | 22（+18 AC ambiguity、+19 cross-layer batch cascade、+20 design over-spec cascade、+21 no data for layer removal、+22 empty-shell agent/interface output） |
| Global Rules | 18 | 25（+20 calibration anchor 必引、+21 sub-artifact 落盘纪律、+22 ablation 安全规则、+23 per-task model tier、+24 intent-injection propagation、+25 data presence gate） |
| 典型可捕获 bug | + harness 自反馈缺失类 | AC 含糊至 Phase 4 才发现 / 跨层任务失败级联整批 / 自评分通胀 / 流水线单向加层无证据 |

---

## v9.4 → v9.5 变化

| 方面 | v9.4 | v9.5 |
|------|------|------|
| 安全审计 | 无 | + Phase 4B /cso 安全审计（OWASP+STRIDE） |
| 性能基线 | 无 | + Phase 5A /benchmark Core Web Vitals 基线（IF FE） |
| 系统化排错 | Ad-hoc 2 次重试 | + Phase 4A /investigate Iron Law 排错协议 |
| 健康度追踪 | 无 | + Phase 7 /health 复合质量分 + 趋势 |
| 必选 skill 数 | 8 | 12（+cso, benchmark, investigate, health） |
| Phase 6 审计表 | 8 行 | 12 行 |
| Batch Gate | spec + contract | + security_audit PASS |
| Finish Gate | build + smoke | + perf_baseline PASS（IF FE） |
| FAILURE MODES | 14 | 16（+安全漏洞漏审, +性能退化静默交付） |
| Global Rules | 14 | 18（+15-18 安全/性能/排错/健康） |
| gstack 依赖 | 1 skill | 5 skills |

---

## v9.3 → v9.4 变化

| 方面 | v9.3 | v9.4 |
|------|------|------|
| 横向同族代码契约 | CTP 6 层 | 保留 |
| 横向同族 UI 命名 | Sibling Scan Mode B | 保留 |
| **纵向跨层字段契约** | **无** | **+ Field Mapping Contract（5 层防御）** |
| Researcher 调研 | §2 前端设计体系 + 同族签名/UI 基线 | + §4 API Field Naming Convention Scan |
| Designer 输出 | §2b Explicit Contracts（CTP） | + §2c Field Mapping Contract Chapter（FE+BE 时强制）|
| Frontend Designer | 读现有组件 + 显式契约 + 多角度评审 | + §2b Honor Field Mapping Contract |
| Implementer 自检 | Peer Read + 交叉检查 | + §1e Field Mapping Adherence + grep 自检 |
| Implementer JSON 输出 | 已有字段 | + `field_mapping: APPLIED/N/A` |
| Reviewer 检查 | Spec + Contract Matrix + UI Naming | + Cross-Layer Field Mapping Check + 6 行严重度矩阵 |
| Reviewer JSON 输出 | 已有字段 | + `field_mapping_consistency` |
| Phase 1 验证门控 | Baseline Signature Table 存在性 | + API Field Naming Convention 块存在性 |
| Phase 2 验证门控 | 多角度评审 | + Field Mapping Contract 章节存在性（FE+BE 时） |
| FAILURE MODES | 13 个 | 14 个（+FAILURE 14: 跨层字段映射不一致）|
| Global Rules | 13 | 14 |
| 典型可捕获 Bug | 同族契约失配 + 层职责漂移 + UI 命名漂移 | + 后端 snake ↔ 前端 camel 无转换 / 前端字段拼写错误 / 命名混用 |

---

## v9.4 五层防御机制（FAILURE 14）

| 层 | Agent / 阶段 | 职责 | 产物 |
|----|-------------|------|------|
| L1 | Researcher §4 | 扫描后端序列化（Pydantic alias / DRF source / Go struct json tags）+ 前端取数路径（fetch/axios/TS interface），识别命名约定与转换边界 | research_brief 中的 "API Field Naming Convention" 块 + JSON `has_api_naming_convention` |
| L2 | Designer §2c | 当 has_frontend ∧ 后端 API 时，强制在 design_doc 中产出"Field Mapping Contract"章节：约定方向 + 转换边界 + 1-3 个代表性端点/字段对 + 例外说明 | design_doc.md 中的 Field Mapping Contract 章节 |
| L3 | Frontend Designer §2b | 前端 spec 的 state/props 字段名必须遵循契约的 frontend names | frontend_spec.md 中字段名与契约一致 |
| L4 | Implementer §1e | 后端 serializer 强制 wire 名；前端读契约名；grep 自检；产出 grep-anchored Evidence Table：端点、wire 字段、declared_conversion、frontend 字段、contract_match=YES/NO；新增 `field_mapping_all_match` | 实现代码 + 文本/JSON 输出 |
| L5 | Phase 4A Orchestrator | 解析 implementer JSON：若 evidence table 中存在 contract_match=NO 或 field_mapping_all_match=false → 立即重新派发 implementer 修复，不让不匹配字段流进 review | state.dag[id] 重试计数 + corrective_findings |
| L6 | Phase 4A.5 micro-loop | THIN MODE reviewer 对比 design doc contract + implementer evidence table；生成 `field_mapping_diff` JSON（matched/mismatched/findings） | micro_loop_verdict = REFINE_REQUIRED/FAIL |
| L7 | Reviewer (Phase 4B) | Cross-Layer Field Mapping Check + 6 行严重度矩阵：无转换层失配=BLOCKER、缺字段=BLOCKER、命名漂移=HIGH、混用=MEDIUM、未消费=LOW；输出 `field_mapping_diff` 与 `field_mapping_consistency` | code_review_report 中的 Cross-Layer 段 + JSON |

注：planner 与 finisher 不参与（DAG 调度无需关心字段名；finisher 的 E2E smoke 已被 L4 grep 自检 + L7 矩阵覆盖，避免重复）。
L4→L6 构成"实现即验证"的闭环：implementer 自证 → orchestrator 机验 → micro-loop reviewer 复核；L7 是最终 batch 兜底。

---

## v8.0 → v9.x 演进总览

| 方面 | v8.0 | v9.0 | v9.1 | v9.2 | v9.3 | v9.4 | v9.5 | v9.6 |
|------|------|------|------|------|------|------|------|------|
| Agent 输出 | 自由文本 | JSON block | JSON block | JSON block | JSON + ui_naming | JSON + field_mapping | JSON + security_audit + perf_baseline + investigate | + ac_review / micro_loop / evidence_table / sub_artifacts |
| 错误处理 | 统一重试 | 三级分类 | 三级分类 | 三级分类 | 三级分类 | 三级分类 | 三级 + /investigate | 三级 + /investigate + UNIVERSAL RETRY PROTOCOL（v9.5.4） |
| 横向代码契约 | 无 | 无 | CTP 6 层 | CTP 6 层 | CTP + UI Naming | CTP + UI Naming | CTP + UI Naming | CTP + UI Naming |
| 横向 UI 契约 | 无 | 无 | 无 | 无 | Sibling Scan Mode B | Sibling Scan Mode B | Sibling Scan Mode B | Sibling Scan Mode B |
| 纵向跨层契约 | 无 | 无 | 无 | 无 | 无 | Field Mapping 5 层 | Field Mapping 5 层 | Field Mapping 5 层 + 设计/实现责任拆分（Evidence Table） |
| **安全审计** | **无** | **无** | **无** | **无** | **无** | **无** | **/cso OWASP+STRIDE** | **/cso OWASP+STRIDE** |
| **性能基线** | **无** | **无** | **无** | **无** | **无** | **无** | **/benchmark CWV** | **/benchmark CWV** |
| **系统排错** | **无** | **无** | **无** | **无** | **无** | **无** | **/investigate Iron Law** | **/investigate Iron Law** |
| **健康度** | **无** | **无** | **无** | **无** | **无** | **无** | **/health 复合分** | **/health + Layer ROI + Ablation 证据** |
| **Sprint contract negotiation** | **无** | **无** | **无** | **无** | **无** | **无** | **无** | **Phase 3B AC 验签** |
| **任务级 micro-loop** | **无** | **无** | **无** | **无** | **无** | **无** | **无** | **Phase 4A.5 THIN MODE（条件触发）** |
| **自评校准** | **无** | **无** | **无** | **无** | **无** | **无** | **无** | **Calibration Anchors（2/5/8 锚定例）** |
| 架构原则 | 无 | 无 | 无 | 6 条可推导 | 6 条可推导 | 6 条可推导 | 6 条可推导 | 6 条可推导 |
| Phase 7 复盘 | 自由格式 | 自由格式 | 自由格式 | 自由格式 | 两张强制表格 | 两张强制表格 | 两张表格 + 健康分 | 两张表格 + 健康分 + Layer ROI + Snapshot + Ablation |
| FAILURE MODES | 7 | 10 | 11 | 12 | 13 | 14 | 16 | 22 |
| Global Rules | 8 | 11 | 12 | 13 | 13 | 14 | 18 | 25 |
| 必选 skill 数 | 8 | 8 | 8 | 8 | 8 | 8 | 12 | 13 |

---

## 已知故障模式

v9.6 记录了 22 个从实际运行中发现的故障模式，每个都有对应的修复措施。关键项：

- **FAILURE 11** (v9.1): 同族实现契约失配 — 单测通过但集成崩溃。修复：CTP 6 层防御（横向代码层）。
- **FAILURE 12** (v9.2): 架构层职责漂移 — 逻辑在错误的层，每次变更波及多层。修复：6 条架构设计原则。
- **FAILURE 13** (v9.3): 同族实现未被发现 — Researcher 遗漏同层文件导致命名/协议/风格不一致。修复：SAME-FAMILY SCAN mandatory + Phase 1 验证门控（横向 UI 层）。
- **FAILURE 14** (v9.4): 跨层字段映射不一致 — 后端 snake_case 序列化、前端 camelCase 读取，中间无转换层 → 运行时 undefined；或前端字段拼写错误（payload.dt vs payload.date）；或同一应用内混用两种命名。修复：5 层防御 Field Mapping Contract（纵向跨层）。
- **FAILURE 15** (v9.5): 安全漏洞漏审 — Reviewer 无安全维度，OWASP Top 10 / STRIDE 类漏洞（XSS、SQLi、SSRF、不安全反序列化）功能层面正确但攻击面已暴露，到生产或渗透测试才被发现。修复：Phase 4B reviewer 强制调用 /cso，security_audit 质量门字段，CRITICAL 漏洞 = BLOCKING。
- **FAILURE 16** (v9.5): 性能退化静默交付 — 无 baseline 比较，Core Web Vitals（LCP/CLS/FID）退化、资源体积膨胀、未压缩新依赖通过所有 lint/type/build 门控。修复：Phase 5A finisher 前端时强制调用 /benchmark，perf_baseline 字段，HIGH 回归 = Finish Gate FAIL。
- **FAILURE 17** (v9.5.4): Dispatch 失败靠直觉重试 — 编排器忘记 corrective prefix / shrinkage / fatal classification，反复重试同样失败的 prompt。修复：UNIVERSAL RETRY PROTOCOL 决策树（CLASSIFY→TRANSIENT×3→CODE/MALFORMED corrective×2→SHRINKAGE×1→BLOCKED），state.dag[id].attempts 全量 trace。
- **FAILURE 18** (v9.6): AC 含糊到 Phase 4 才暴露 — design_doc 验收准则没有可机验性，DAG 跑完才发现"这个 AC 到底要做啥"。修复：Phase 3B AC 验签（reviewer fast-mode 评每条 CLEAR/AMBIGUOUS/UNCOVERED/CONTRADICTORY），planner §2e single corrective replan。
- **FAILURE 19** (v9.6): 跨层任务失败级联整批 — T_contract_* / 字段映射边界任务在 batch_full 阶段才被发现失配，整个 batch 重做。修复：Phase 4A.5 micro-loop（条件触发，THIN MODE 3 检查，最多 2 轮 refine）+ implementer §1g Corrective-Findings Loop Handler。
- **FAILURE 20** (v9.6): 设计过度规约级联 — designer 在 spec 阶段就把 per-field 4 列映射表写死，实现一改字段名就连锁修改 spec+frontend_spec+plan，且字段名实际是实现产物不是设计产物。修复：designer §2c 改为 ≤12 行方向声明，implementer §1e 产 grep-anchored Evidence Table，reviewer diff（生成/评估分离）。
- **FAILURE 21** (v9.6): 流水线单向加层无证据 — 8.0 至 9.5 必选 skill 从 8 长到 13，FAILURE 模式从 7 长到 16，无任何裁层动作；没有"哪层贡献了什么发现"的数据，无法判断何层可砍。修复：Phase 7 强制 Layer ROI 表（14 行 × 3 run 滚动窗口）+ Ablation Run 协议（唯一可信删层证据，安全规则：一次只动一层、永不 ablate 硬正确性门）。
- **FAILURE 22** (v9.6.1): Agent/接口"返回了但无数据" — 输出格式合法、status=PASS，但关键载荷为空（research_brief 无发现、change_registry 空、API response 无字段、前端无 EMPTY 状态），导致"处理中没数据"的 bug 逃过所有门控。修复：把"数据存在性"提升为独立门控——UNIVERSAL DISPATCH PROTOCOL 解析 JSON 后校验关键字段非空；Phase 1/4 分别校验 research_brief / change_registry 有 actionable 内容；Reviewer 跨层字段映射检查增加 Data Presence Check。

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v9.6.1 | 2026-06-28 | 新增 FAILURE 22：Agent/接口"返回了但无数据"——把数据存在性提升为独立门控。UNIVERSAL DISPATCH PROTOCOL 解析 JSON 后校验关键字段非空；Phase 1 校验 research_brief 有 actionable 发现；Phase 4 校验 implementer change_registry 非空；Implementer/Reviewer agent 增加 DATA PRESENCE 规则；Reviewer 跨层字段映射检查新增 Data Presence Check（后端须返回数据、前端须处理 EMPTY 状态）。Global Rules 22→25（+23 per-task model tier、+24 intent-injection propagation、+25 data presence gate）。<br><br>强化跨层字段映射一致性：Designer §2c 增加"代表性端点/字段对"要求，Implementer §1e Evidence Table 增加 endpoint + declared_conversion + contract_match 列 + `field_mapping_all_match` 字段，Phase 4A Orchestrator 机验 evidence table（不匹配则立即 corrective retry），micro-loop 与 Reviewer 输出结构化 `field_mapping_diff` JSON。 |
| v9.6 | 2026-06-13 | Anthropic [harness-design-long-running-apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) 对齐：(1) Phase 3B AC 验签（reviewer fast-mode 评每条 AC，planner §2e 单次 corrective replan）；(2) Phase 4A.5 任务级 micro-loop（条件触发：T_contract_*/touches_field_mapping_boundary；reviewer THIN MODE 3 检查；最多 2 轮 refine；implementer §1g 处理回灌）；(3) Field Mapping 责任拆分（designer §2c 改为 ≤12 行方向声明，implementer §1e 产 grep-anchored Evidence Table，reviewer diff）；(4) Per-Skill Sub-Artifact 协议（reviewer 把证据写入 `review_artifact_dir/batch-N-*.md`，主报告精简引用）；(5) Calibration Anchors（每维度 2/5/8 锚定例，10 分保留，抗自评分通胀）；(6) Layer ROI 表（14 行 × 3 run 滚动窗口）+ Ablation Run 协议（唯一可信删层证据，安全规则）；(7) Harness Assumption Snapshot；(8) Phase 6 Checklist E（9 行）；(9) reviewer 三模式路由（batch_full/micro_loop/ac_negotiation），planner §2d per-task tagging；(10) FAILURE 18-21 + Global Rules 20-22；必选 skill 数 12→13；典型调度次数 6-9→7-11。 |
| v9.5 | 2026-05-18 | gstack 4 技能集成（安全 + 性能 + 排错 + 健康度）：FAILURE 15+16 + Global Rules 15-18；reviewer 集成 /cso（OWASP+STRIDE，security_audit 质量门）；finisher 集成 /benchmark（Core Web Vitals 基线，perf_baseline 字段，前端时强制）；implementer 集成 /investigate（Iron Law 系统化排错协议，3 cycle 收敛）；Phase 7 集成 /health（5 维度复合质量分 + 趋势）；必选 skill 数 8→12；Phase 6 审计表 8 行→12 行；gstack 依赖从 1 个扩展到 5 个。 |
| v9.4 | 2026-05-18 | Cross-Layer Field Mapping Contract（纵向跨层）：FAILURE 14 + 5 层防御（Researcher §4 API naming scan / Designer §2c contract chapter / Frontend Designer §2b honor contract / Implementer §1e adherence + grep self-check / Reviewer cross-layer check + 6-row severity matrix）；Phase 1+2 双层验证门控；Global Rule 14（跨层映射失配=BLOCKER）。 |
| v9.3 | 2026-05-17 | Same-Family Sibling Scan（横向 UI 层）：Mode B（HTML ID/JS/CSS 命名基线）；FAILURE 13；Reviewer UI Naming Consistency + Severity Matrix；Phase 1 mandatory scan + 验证门控；Phase 5B Sibling Contract Consistency Check；Phase 7 两张强制复盘表（需求追溯 + 兄弟一致性）。 |
| v9.2 | 2026-05-17 | 架构设计原则：6 条可推导规则（层职责单一性、协议原生性、消息显式判别、配置边界规范化、抽象层污染防范、用户可观测完整性）；FAILURE 12；Global Rule 13。 |
| v9.1 | 2026-05-07 | 契约一致性层 CTP（横向代码层）：FAILURE 11 + 6 层防御。 |
| v9.0 | 2026-05-07 | 执行可靠性：JSON 输出、三级错误分类、并发锁、空闲超时、确定性恢复。 |
| v8.0 | 2026-05-04 | 结构优化：SKILL.md 精简脊柱 + 8 phase 文件；Phase 5B 独立验证；前端三层防御。 |
| v7.0 | 2026-05-04 | 前端设计规范全链路传递；合并 validator→finisher；移除 TDD。 |
| v6.2 | 2026-04-26 | 路径传递调度，部署链检查，缓存破解审计。 |
