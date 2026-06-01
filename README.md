# s2s

独立工程：原生实时语音大模型（Speech-to-Speech）spike 与试验。与 one-eino 主仓解耦；结论成熟后再决定是否回迁。

## 已拍板（2026-05-31）

| 项 | 决策 |
| --- | --- |
| 根目录 | `D:\s2s` |
| 版本管理 | 独立 Git 仓库 |
| 布局 | 按 spike 分子目录（`src/opens2s`、`src/volc-realtime`、`src/stepfun-realtime`），共享一个 venv |
| Python | **3.10**（OpenS2S 上游推荐；本机若未安装见下方） |
| 权重 / 缓存 | `models/`、`cache/`，不进 git |

## 目录结构

```text
D:\s2s\
├── README.md
├── docs/                 # 决策、竞品 references
├── src/
│   ├── opens2s/          # OpenS2S（vendored）
│   ├── minimind/         # MiniMind 文本 LLM 教学复现 spike
│   ├── volc-realtime/    # 火山 RealtimeAPI spike
│   └── stepfun-realtime/ # 阶跃 StepAudio Realtime spike
├── env/.venv/            # OpenS2S 虚拟环境（bootstrap 创建）
├── env/.venv-minimind/   # MiniMind 虚拟环境（bootstrap-minimind 创建）
├── models/               # HF 权重（gitignore）
├── cache/huggingface/    # HF_HOME（gitignore）
├── logs/
└── scripts/              # env.ps1、bootstrap.ps1
```

## 快速开始

完整安装见 **[`docs/INSTALL.md`](docs/INSTALL.md)**（OpenS2S：L1 + L2；MiniMind：M1 + L2，见 [MiniMind 章节](docs/INSTALL.md#minimind-教学复现)）。

### L1 概要

1. **手动安装 Python 3.10**（[python.org](https://www.python.org/downloads/release/python-31011/) 或 `choco install python310 -y`）
2. 在仓库根目录：

```powershell
.\scripts\bootstrap.ps1
. .\scripts\env.ps1
```

### L2 概要（OpenS2S）

```powershell
.\scripts\download-opens2s-models.ps1
.\scripts\check-l2-opens2s.ps1
```

启动服务见 [`src/opens2s/SPIKE.md`](src/opens2s/SPIKE.md)。

## 环境变量（scripts/env.ps1）

| 变量 | 指向 |
| --- | --- |
| `S2S_ROOT` | `D:\s2s` |
| `HF_HOME` | `D:\s2s\cache\huggingface` |
| `HUGGINGFACE_HUB_CACHE` | 同上 `\hub` |

## 竞品与背景

见 [`docs/references/`](docs/references/README.md)。

## 下一步（在 Cursor 中切到本目录后继续）

- [ ] 跑通 L1：`.\scripts\bootstrap.ps1`
- [ ] 跑通 L2：`download-opens2s-models.ps1` + `check-l2-opens2s.ps1`
- [ ] 安装 ffmpeg 并加入 PATH（L2 前置）
- [ ] 在 `docs/` 继续 grill / 写 spike 结论
