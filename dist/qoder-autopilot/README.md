# Qoder Autopilot — Qoder Plugin

多 Agent 自动开发流水线，从需求到发布的全流程编排。本目录是把上游工程
[`vipdocker/qoder-autopilot`](https://github.com/vipdocker/qoder-autopilot)
打包为 **Qoder 原生插件** 的产物（可复制、可分发）。

## 这个插件做什么

`qoder-autopilot` 是一个编排器 skill，作为「精简调度脊柱」在主会话运行，通过 `Task()`
调度 7 个专业 Agent 完成一条完整的软件开发流水线：

```
Phase 0 INTAKE → 1 RESEARCH → 2 DESIGN → 3 PLAN → 3B AC-NEGOTIATE
              → 4 EXECUTE(+4A.5 micro-loop) → 5 FINISH → 6 AUDIT → 7 EVOLVE
```

触发词：`qoder-autopilot` / `qoder autopilot` / `自动开发` / `全自动` / `一键开发` /
`autopilot` / `端到端开发` / `end-to-end development`。

## 插件内容

| 组件 | 路径 | 数量 | 说明 |
|------|------|------|------|
| Skill | `skills/qoder-autopilot/` | 1 | 编排器脊柱 `SKILL.md` + `reference.md` + `self-check-protocol.md` + `phases/`（9 个阶段文件） |
| Agents | `agents/` | 7 | researcher / designer / frontend-designer / planner / implementer / reviewer / finisher |
| Logo | `assets/avatar.svg` | 1 | 见下文「Logo 来源」 |
| Manifest | `.qoder-plugin/plugin.json` | 1 | Qoder 插件清单，声明 `skills` + `agents` |

```
qoder-autopilot/
├── .qoder-plugin/plugin.json
├── README.md
├── assets/avatar.svg
├── skills/qoder-autopilot/
│   ├── SKILL.md
│   ├── reference.md
│   ├── self-check-protocol.md
│   └── phases/phase-{0,1,2,3,3b,4,5,6,7}-*.md   (9 files)
└── agents/engineering-autopilot-*.md            (7 files)
```

## 来源溯源

- **源工程**：本地目录 `/Users/duff/Documents/Lingma-Demo/qoder-autopilot`
- **上游仓库**：https://github.com/vipdocker/qoder-autopilot
- **版本**：v9.7.0（与源 `skill/SKILL.md` frontmatter `version` 一致）
- **许可证**：Apache-2.0（见源工程 `LICENSE`）
- **打包方式**：源工程的 `skill/` → 插件 `skills/qoder-autopilot/`；源 `agents/` → 插件 `agents/`。
  所有 skill / agent / phase 文件按原样复制，未改写工作流、触发条件、引用关系与安全约束。

### Logo 来源

源工程无 logo。`assets/avatar.svg` 为本插件新生成的本地占位图标（流水线节点 + 中心
autopilot 星形），无外部引用、无版权素材。可按需替换为品牌图标。

## 依赖项（重要）

⚠️ `qoder-autopilot` **不是一个独立 skill**，而是一个调度多个上游 skill 的**编排器**。
运行流水线时，7 个 Agent 会通过 Skill 工具调用以下 **13 个必选 skill**。这些 skill
来自三个上游项目，**不随本插件分发**，需另行安装：

| 来源 | 提供的 skill |
|------|--------------|
| [obra/superpowers](https://github.com/obra/superpowers) | brainstorming · writing-plans · dispatching-parallel-agents · requesting-code-review · receiving-code-review · finishing-a-development-branch |
| [garrytan/gstack](https://github.com/garrytan/gstack) | frontend-design · cso · benchmark · investigate · health |
| [prompts.chat](https://prompts.chat) | ast-code-analysis-superpower |
| 内联 | frontend-design-thinking（内联于 frontend-designer agent，无需安装） |

可选依赖：`agent-browser`（gstack，前端冒烟/视觉检查）、`gbrain` MCP（历史决策查询/复盘落库）。
未配置时按源工程约定降级处理。

> 任一必选 skill 缺失都会导致对应 Phase 的 Agent 调用失败。安装本插件前，请先按各上游项目
> README 完成 superpowers + gstack + prompts.chat 的安装与验证。

## 安装与使用

### 方式 A：作为 Qoder 插件安装（推荐）

本目录即一个标准 Qoder 插件根（含 `.qoder-plugin/plugin.json`），可通过 Qoder 插件机制安装。
安装后，编排器 skill 与 7 个 agent 会被 Qoder 识别；在会话中用上述触发词即可启动流水线。

### 方式 B：源工程脚本安装（上游原生方式）

源工程自带 `install.sh` / `uninstall.sh` / `validate.sh`，会把 skill 安装到
`~/.agents/skills/qoder-autopilot/`（并软链到 `~/.qoderwork/skills/`），把 agents 安装到
`~/.qoder/agents/` 与 `~/.qoderwork/agents/`。

> **注意**：`SKILL.md` 内部通过 `Read("~/.qoder/agents/engineering-autopilot-{role}.md")`
> 读取 agent 文件（路径传递协议，避免污染编排器上下文）。因此运行时 agent 文件需可从
> `~/.qoder/agents/` 读取——这与方式 B 的安装位置一致。若仅用方式 A 安装，请确保 7 个
> agent 文件同样可在 `~/.qoder/agents/` 下访问（可用源工程 `install.sh` 补齐 agent 安装）。

## 省略的文件

以下源工程文件为「安装工具 / 仓库元数据」，非插件运行时内容，未纳入插件包：

- `install.sh` / `uninstall.sh` / `validate.sh` — 源工程的手动安装与跨文件契约校验脚本
  （方式 B 使用；Qoder 插件安装由 Qoder 自身管理）。
- `README.md`（源工程根）— 含完整版本演进史与故障模式说明；本插件 README 已提炼关键信息，
  详细版本历史请见上游仓库。
- `.git/` / `.gitignore` / `LICENSE` — 仓库元数据（许可证信息已在 `plugin.json.license`
  与本文件标注）。

未发现被 `SKILL.md` 引用却缺失的支持文件：`reference.md`、`self-check-protocol.md`、
`phases/*.md`（相对引用）与 7 个 agent 文件（`~/.qoder/agents/` 引用）均已随包提供或有明确安装位置。

## 校验

使用 create-plugin 附带的离线校验器：

```bash
python3 <create-plugin>/scripts/validate_qoder_plugin.py <此目录>
```

## 打包记录

- **校验命令**：`python3 create-plugin/skills/create-plugin/scripts/validate_qoder_plugin.py dist/qoder-autopilot`
- **校验结果**：`OK: no issues found`（exit 0）
- **校验覆盖**：`.qoder-plugin/plugin.json` 合法 JSON 且含 `name`/`version`；`skills`+`agents`
  组件路径均以 `./` 开头、不越界、指向真实目录；`SKILL.md` frontmatter 含 `name`+`description`；
  未打包本地运行态或非 Qoder 清单目录。
- **文件计数**：1 skill（12 文件：SKILL.md + reference.md + self-check-protocol.md + 9 phases）
  + 7 agents + 1 logo + 1 manifest。
