# s2s

> 独立工程：原生实时语音大模型（Speech-to-Speech）spike 与试验。与 one-eino 主仓解耦；结论成熟后再决定是否回迁。

## 仓库结构

```
D:\s2s\
├── README.md
├── docs/                      # 决策、竞品 references
├── scripts/
│   ├── bootstrap.ps1          # 脚手架 + venv
│   └── env.ps1                # 环境变量 + 激活 venv
├── src/
│   ├── opens2s/               # OpenS2S 本地 S2S（已迁入）
│   ├── volc-realtime/         # 火山 RealtimeAPI spike（占位）
│   └── stepfun-realtime/      # 阶跃 StepAudio spike（占位）
├── env/.venv/                 # Python 3.10 虚拟环境
├── models/                    # HF 权重（gitignore）
├── cache/huggingface/         # HF 缓存（gitignore）
├── logs/
└── .harness/                  # 知识库、workflow、session
```

## 技术栈

| 语言 / 框架 | 版本 / 说明 | 位置 |
| --- | --- | --- |
| Python | 3.10 | 全工程统一 |
| PyTorch | 2.4.0+cu124 | `src/opens2s/requirements.txt` |
| transformers | 4.51.0 | OpenS2S |
| FastAPI + uvicorn | 0.110.3 / 0.32.0 | Controller / Worker |
| Gradio | 4.44.1 | Web Demo |
| PyTorch Lightning | 2.5.1 | 训练 |

## 服务架构

```
                    ┌─────────────────┐
                    │  web_demo.py    │  Gradio :8888
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  controller.py  │  worker 调度
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ model_worker.py │  GPU 推理 + 流解码
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     models/casia-opens2s   glm-4-voice-decoder   cache/huggingface
```

云 spike（`volc-realtime`、`stepfun-realtime`）待实现，预期独立 WebSocket 客户端。

## 域清单

| name | type | lang | path | 说明 |
| --- | --- | --- | --- | --- |
| s2s | backend | python | `./` | S2S spike 试验工程（OpenS2S + 云 API 占位） |

## 常用命令

```powershell
# 初始化
.\scripts\bootstrap.ps1
. .\scripts\env.ps1
pip install -r src\opens2s\requirements.txt

# 验证（语法）
python -m compileall -q src/opens2s

# OpenS2S 推理（需权重，在 src\opens2s 下）
python controller.py
python model_worker.py --model-path D:\s2s\models\casia-opens2s --flow-path D:\s2s\models\thudm-glm4-voice-decoder
python web_demo.py --port 8888
```

## 全局约定

- **禁止自动提交**：除非用户明确要求，不要执行 `git commit`
- **提交格式**：`<type>(<scope>): <subject>`
- **文档语言**：人类可读文档默认**简体中文**
- **Windows 终端**：勿用 `&&` 连接命令
- 其他约定见 **`.harness/knowledge/`** 与 **`.harness/workflow/`**

## Agent skills

### Issue tracker

Issue 与 PRD 以 markdown 存放在 **`.scratch/<feature-slug>/`**。详见 `docs/agents/issue-tracker.md`。

### Triage labels

五个分拣角色（`needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human`、`wontfix`）写入 issue 文件 `Status:` frontmatter。详见 `docs/agents/triage-labels.md`。

### Domain docs

**单上下文**布局：根目录 `CONTEXT.md` + `docs/adr/`（懒创建）；已有 grill 决策见 `docs/DECISIONS.md`。详见 `docs/agents/domain.md`。

## Agent 工作流（harness）

### Issue 与分拣

- Issue 路径：**`.scratch/<feature-slug>/issues/`**（见 `docs/agents/issue-tracker.md`）
- 分拣标签：**`docs/agents/triage-labels.md`**
- 决策记录：**`docs/DECISIONS.md`**；竞品索引：**`docs/references/`**

### 功能工作流

做**新功能、重构、修 bug** 前，先 **Read** **`.harness/workflow/feature-workflow.md`**：

1. 按文首「先选哪一种工作类型」进入对应章节（**只跟一条流程，不要混用**）
2. 遵守文内「全局硬规则」（开工前有 scope、收工前跑 `validate_commands`）
3. 未在该章节列出的步骤**默认不做**

### 实现阶段（写代码时）

1. 读取 **`.harness/knowledge/index.yaml`** 中目标 domain 的 `rules` 与 `skills[]`
2. 先读 **`.harness/knowledge/query/s2s.md`**
3. 在 `domain.path` 下找相似实现
4. 按分层实现并运行 `validate_commands`

## 知识体系（渐进式披露）

### 第一层：Rules

**`.cursor/rules/`**（`*.mdc`）与 **`.claude/rules/`**（`*.md`，若存在）按各文件 frontmatter 的 `paths` 匹配。

### 第二层：按域查询说明

**`.harness/knowledge/query/s2s.md`** — 说明该 domain 应先读哪些知识文件。

### 第三层：Domain 知识文档

**`.harness/knowledge/domains/backend/`** 下四份文档：

- `01-architecture.md`
- `02-business-domains.md`
- `03-infra-patterns.md`
- `04-dev-guide.md`

## 自学习与索引

- **增量学习**：**learn** 技能；先 **Read** **`.harness/knowledge/learner-workflow.md`**
- **全量 / 首次**：**init-knowledge** 技能
- **项目索引**：**`.harness/knowledge/index.yaml`**
