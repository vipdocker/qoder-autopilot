# Qoder Autopilot v9.5 — 安装指南

## 概述

Qoder Autopilot 是一个多 Agent 编排技能，驱动完整的 superpowers 开发流水线。v9.5 在 v9.4 的基础上新增 **4 个 gstack 技能集成**：安全审计（/cso）、性能基线（/benchmark）、系统化排错（/investigate）、工程质量分（/health），补全了 pipeline 在安全维度、性能可观测性、调试质效和长期健康追踪上的盲区。调度 7 个专业 Agent，覆盖调研、设计、规划、实现、代码审查、收尾和独立验证。

### 四类正交的质量维度

| 维度 | 代际 | 描述 | 典型 bug |
|------|------|------|----------|
| 横向 · 代码层 | v9.1 CTP | 同层兄弟实现接口签名一致 | str vs date 类型契约失配 |
| 横向 · UI 层 | v9.3 Sibling Scan | 同容器 HTML/JS/CSS 命名一致 | mdAIStartBtn vs mdAiStartBtn |
| 纵向 · 跨层 | v9.4 Field Mapping | 后端↔前端字段名稳定映射 | user_name vs userName 无转换 → undefined |
| **安全+性能+质效** | **v9.5 gstack 补强** | **安全审计 + 性能基线 + 系统排错 + 健康度** | **XSS 漏审 / LCP 退化 / ad-hoc 排错失败** |

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
│
├── Phase 0: 需求收集 ─────── 主会话（产品化需求收集 + gbrain 查询）
├── Phase 1: 调研 ────────── Task() → researcher [Kimi-K2.5]
│                              ├── 前端设计体系 + 同族签名快照 + UI 命名基线（v9.3）
│                              └── §4 API Field Naming Convention Scan（v9.4）
├── Phase 2A: 设计 ───────── Task() → designer [Premium]
│                              ├── §2b Explicit Contracts（v9.1 CTP）
│                              └── §2c Field Mapping Contract Chapter（v9.4，前后端皆有时强制）
├── Phase 2B: 前端设计 ────── Task() → frontend-designer（若有前端）[Premium]
│                              ├── 读取项目现有组件 + 显式契约章节 + 多角度评审 + 人工确认
│                              └── §2b Honor Field Mapping Contract（v9.4）
├── Phase 3: 规划 ────────── Task() → planner [Premium]
│                              └── DAG + T_contract_* + 前端规范对齐
├── Phase 4A: 实现 ───────── Task() × N → implementer（按任务）[Premium]
│                              ├── Peer Read-Before-Code + 交叉检查项目现有组件
│                              ├── §1e Field Mapping Adherence + grep self-check（v9.4）
│                              └── §3b /investigate 系统化排错（v9.5，self-verify FAIL 时强制）
├── Phase 4B: 审查 ───────── Task() → reviewer [Premium]
│                              ├── spec合规 + Contract Matrix + UI Naming Consistency
│                              ├── Cross-Layer Field Mapping Check + 6 行严重度矩阵（v9.4）
│                              └── §5 /cso 安全审计 + Security Severity Matrix（v9.5）
├── Phase 5A: 收尾 ───────── Task() → finisher [Kimi-K2.6]
│                              ├── type/lint/build + E2E smoke + 分支整理
│                              └── §3c /benchmark 性能基线（v9.5，前端时强制）
├── Phase 5B: 独立验证 ────── Task() → verifier
│                              └── 架构合规 + 前端风格合规 + Sibling Consistency Check
│                              └── 人工确认（展示 5A + 5B 结果）
├── Phase 6: 审计 ────────── 主会话（12 技能清单 + 补救）
└── Phase 7: 进化 ────────── 主会话（复盘 + 两张强制表格 + /health 健康分 + gbrain → .retro.md）
```

典型调度次数：6-9（含必须的 5B 验证）。

### 安装路径

```
Skill (主目录):  ~/.agents/skills/qoder-autopilot/     (11 files)
Skill (软链接): ~/.qoderwork/skills/qoder-autopilot → 主目录
Agents:         ~/.qoder/agents/                       (7 files)
Agents (镜像):  ~/.qoderwork/agents/                   (7 files)
```

### 12 个必选技能

> 以下技能分别来自 **superpowers**、**gstack**、**prompts.chat** 三个上游项目，安装本 skill 之前必须先完成它们的安装。详见下文 [依赖项](#依赖项--dependencies) 章节。

| # | 技能 | 来源 | 阶段 | Agent | 条件 |
|---|------|------|------|-------|------|
| 1 | brainstorming | superpowers | 设计 | designer | ALWAYS |
| 2 | frontend-design | gstack | 设计 | frontend-designer | IF FRONT |
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
│   ├── SKILL.md               ← v9.5 编排器精简脊柱（主入口）
│   ├── reference.md           ← 质量门、错误分类、契约一致性、资源限制
│   ├── self-check-protocol.md ← 阶段退出验证协议
│   └── phases/                ← Phase 详情（按需加载）
│       ├── phase-0-intake.md
│       ├── phase-1-research.md    ← v9.3: SAME-FAMILY SCAN, v9.4: API FIELD NAMING SCAN
│       ├── phase-2-design.md      ← v9.4: FIELD MAPPING CONTRACT mandatory
│       ├── phase-3-plan.md
│       ├── phase-4-execute.md
│       ├── phase-5-finish.md      ← v9.3: Sibling Consistency Check
│       ├── phase-6-done.md
│       └── phase-7-evolve.md      ← v9.3: 两张强制复盘表格
└── agents/                    ← Agent 文件（→ ~/.qoder/agents/ + ~/.qoderwork/agents/）
    ├── engineering-autopilot-researcher.md         ← v9.3 Mode B + v9.4 §4 API naming scan
    ├── engineering-autopilot-designer.md           ← v9.4 §2c Field Mapping Contract chapter
    ├── engineering-autopilot-frontend-designer.md  ← v9.4 §2b Honor Field Mapping Contract
    ├── engineering-autopilot-planner.md
    ├── engineering-autopilot-implementer.md        ← v9.4 §1e Field Mapping + v9.5 §3b /investigate
    ├── engineering-autopilot-reviewer.md           ← v9.4 Cross-Layer Check + v9.5 §5 /cso
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

### 必选 skill（12 个，分布在三个上游）

来源详见上文 [12 个必选技能](#12-个必选技能) 表。

- 来自 **superpowers**（6 个）：`brainstorming` · `writing-plans` · `dispatching-parallel-agents` · `requesting-code-review` · `receiving-code-review` · `finishing-a-development-branch`
- 来自 **gstack**（5 个）：`frontend-design` · `cso` · `benchmark` · `investigate` · `health`
- 来自 **prompts.chat**（1 个）：`ast-code-analysis-superpower`

任一缺失都会导致对应 Phase 的 Agent 调用失败。

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
1. 安装 skill 到 `~/.agents/skills/qoder-autopilot/`（11 文件）
2. 创建软链接 `~/.qoderwork/skills/qoder-autopilot` → 主目录
3. 安装 agents 到 `~/.qoder/agents/` + `~/.qoderwork/agents/`（各 7 文件）
4. 自动清理旧版遗留（validator agent、~/.qoder/skills/ 旧路径）
5. 验证文件数量

### 卸载

```bash
bash uninstall.sh
```

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
| L2 | Designer §2c | 当 has_frontend ∧ 后端 API 时，强制在 design_doc 中产出"Field Mapping Contract"章节：每端点表格（wire \| consumed \| type \| example \| notes）+ 转换点 + 例外说明 + 显式一致性 diff | design_doc.md 中的 Field Mapping Contract 章节 |
| L3 | Frontend Designer §2b | 前端 spec 的 state/props 字段名必须遵循契约的 frontend names | frontend_spec.md 中字段名与契约一致 |
| L4 | Implementer §1e | 后端 serializer 强制 wire 名（alias 或 source）；前端读契约名；grep 自检；产出 `field_mapping: APPLIED/N/A` | 实现代码 + 文本+JSON 输出 |
| L5 | Reviewer | Cross-Layer Field Mapping Check + 6 行严重度矩阵：无转换层失配=BLOCKER、缺字段=BLOCKER、命名漂移=HIGH、混用=MEDIUM、未消费=LOW；Spec-Gate FAIL(HIGH) 当 FE+BE 但 design 缺章节 | code_review_report 中的 Cross-Layer 段 + JSON `field_mapping_consistency` |

注：planner 与 finisher 不参与（DAG 调度无需关心字段名；finisher 的 E2E smoke 已被 L4 grep 自检 + L5 矩阵覆盖，避免重复）。

---

## v8.0 → v9.x 演进总览

| 方面 | v8.0 | v9.0 | v9.1 | v9.2 | v9.3 | v9.4 | v9.5 |
|------|------|------|------|------|------|------|------|
| Agent 输出 | 自由文本 | JSON block | JSON block | JSON block | JSON + ui_naming | JSON + field_mapping | JSON + security_audit + perf_baseline + investigate |
| 错误处理 | 统一重试 | 三级分类 | 三级分类 | 三级分类 | 三级分类 | 三级分类 | 三级 + /investigate |
| 横向代码契约 | 无 | 无 | CTP 6 层 | CTP 6 层 | CTP + UI Naming | CTP + UI Naming | CTP + UI Naming |
| 横向 UI 契约 | 无 | 无 | 无 | 无 | Sibling Scan Mode B | Sibling Scan Mode B | Sibling Scan Mode B |
| 纵向跨层契约 | 无 | 无 | 无 | 无 | 无 | Field Mapping 5 层 | Field Mapping 5 层 |
| **安全审计** | **无** | **无** | **无** | **无** | **无** | **无** | **/cso OWASP+STRIDE** |
| **性能基线** | **无** | **无** | **无** | **无** | **无** | **无** | **/benchmark CWV** |
| **系统排错** | **无** | **无** | **无** | **无** | **无** | **无** | **/investigate Iron Law** |
| **健康度** | **无** | **无** | **无** | **无** | **无** | **无** | **/health 复合分** |
| 架构原则 | 无 | 无 | 无 | 6 条可推导 | 6 条可推导 | 6 条可推导 | 6 条可推导 |
| Phase 7 复盘 | 自由格式 | 自由格式 | 自由格式 | 自由格式 | 两张强制表格 | 两张强制表格 | 两张表格 + 健康分 |
| FAILURE MODES | 7 | 10 | 11 | 12 | 13 | 14 | 16 |
| Global Rules | 8 | 11 | 12 | 13 | 13 | 14 | 18 |
| 必选 skill 数 | 8 | 8 | 8 | 8 | 8 | 8 | 12 |

---

## 已知故障模式

v9.5 记录了 16 个从实际运行中发现的故障模式，每个都有对应的修复措施。关键项：

- **FAILURE 11** (v9.1): 同族实现契约失配 — 单测通过但集成崩溃。修复：CTP 6 层防御（横向代码层）。
- **FAILURE 12** (v9.2): 架构层职责漂移 — 逻辑在错误的层，每次变更波及多层。修复：6 条架构设计原则。
- **FAILURE 13** (v9.3): 同族实现未被发现 — Researcher 遗漏同层文件导致命名/协议/风格不一致。修复：SAME-FAMILY SCAN mandatory + Phase 1 验证门控（横向 UI 层）。
- **FAILURE 14** (v9.4): 跨层字段映射不一致 — 后端 snake_case 序列化、前端 camelCase 读取，中间无转换层 → 运行时 undefined；或前端字段拼写错误（payload.dt vs payload.date）；或同一应用内混用两种命名。修复：5 层防御 Field Mapping Contract（纵向跨层）。
- **FAILURE 15** (v9.5): 安全漏洞漏审 — Reviewer 无安全维度，OWASP Top 10 / STRIDE 类漏洞（XSS、SQLi、SSRF、不安全反序列化）功能层面正确但攻击面已暴露，到生产或渗透测试才被发现。修复：Phase 4B reviewer 强制调用 /cso，security_audit 质量门字段，CRITICAL 漏洞 = BLOCKING。
- **FAILURE 16** (v9.5): 性能退化静默交付 — 无 baseline 比较，Core Web Vitals（LCP/CLS/FID）退化、资源体积膨胀、未压缩新依赖通过所有 lint/type/build 门控。修复：Phase 5A finisher 前端时强制调用 /benchmark，perf_baseline 字段，HIGH 回归 = Finish Gate FAIL。

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v9.5 | 2026-05-18 | gstack 4 技能集成（安全 + 性能 + 排错 + 健康度）：FAILURE 15+16 + Global Rules 15-18；reviewer 集成 /cso（OWASP+STRIDE，security_audit 质量门）；finisher 集成 /benchmark（Core Web Vitals 基线，perf_baseline 字段，前端时强制）；implementer 集成 /investigate（Iron Law 系统化排错协议，3 cycle 收敛）；Phase 7 集成 /health（5 维度复合质量分 + 趋势）；必选 skill 数 8→12；Phase 6 审计表 8 行→12 行；gstack 依赖从 1 个扩展到 5 个。 |
| v9.4 | 2026-05-18 | Cross-Layer Field Mapping Contract（纵向跨层）：FAILURE 14 + 5 层防御（Researcher §4 API naming scan / Designer §2c contract chapter / Frontend Designer §2b honor contract / Implementer §1e adherence + grep self-check / Reviewer cross-layer check + 6-row severity matrix）；Phase 1+2 双层验证门控；Global Rule 14（跨层映射失配=BLOCKER）。 |
| v9.3 | 2026-05-17 | Same-Family Sibling Scan（横向 UI 层）：Mode B（HTML ID/JS/CSS 命名基线）；FAILURE 13；Reviewer UI Naming Consistency + Severity Matrix；Phase 1 mandatory scan + 验证门控；Phase 5B Sibling Contract Consistency Check；Phase 7 两张强制复盘表（需求追溯 + 兄弟一致性）。 |
| v9.2 | 2026-05-17 | 架构设计原则：6 条可推导规则（层职责单一性、协议原生性、消息显式判别、配置边界规范化、抽象层污染防范、用户可观测完整性）；FAILURE 12；Global Rule 13。 |
| v9.1 | 2026-05-07 | 契约一致性层 CTP（横向代码层）：FAILURE 11 + 6 层防御。 |
| v9.0 | 2026-05-07 | 执行可靠性：JSON 输出、三级错误分类、并发锁、空闲超时、确定性恢复。 |
| v8.0 | 2026-05-04 | 结构优化：SKILL.md 精简脊柱 + 8 phase 文件；Phase 5B 独立验证；前端三层防御。 |
| v7.0 | 2026-05-04 | 前端设计规范全链路传递；合并 validator→finisher；移除 TDD。 |
| v6.2 | 2026-04-26 | 路径传递调度，部署链检查，缓存破解审计。 |
