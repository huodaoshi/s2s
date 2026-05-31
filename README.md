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
│   ├── opens2s/          # OpenS2S 上游 clone
│   ├── volc-realtime/    # 火山 RealtimeAPI spike
│   └── stepfun-realtime/ # 阶跃 StepAudio Realtime spike
├── env/.venv/            # Python 3.10 虚拟环境（bootstrap 创建）
├── models/               # HF 权重（gitignore）
├── cache/huggingface/    # HF_HOME（gitignore）
├── logs/
└── scripts/              # env.ps1、bootstrap.ps1
```

## 快速开始

### 1. 安装 Python 3.10

本机当前仅有 3.11/3.12 时，需先装 3.10，例如：

```powershell
choco install python310 -y
```

或从 [python.org](https://www.python.org/downloads/release/python-31011/) 安装，并确认：

```powershell
python3.10 --version
```

### 2. 初始化环境

在 **本仓库根目录** 打开 PowerShell：

```powershell
.\scripts\bootstrap.ps1
.\scripts\env.ps1
```

### 3. OpenS2S（首个 spike）

```powershell
# 若尚未 clone
git clone https://github.com/CASIA-LM/OpenS2S.git src\opens2s

# 安装依赖（需已激活 env\.venv 且已 source env.ps1）
pip install -r src\opens2s\requirements.txt
```

权重下载与启动步骤见 `src/opens2s/README.md`。

## 环境变量（scripts/env.ps1）

| 变量 | 指向 |
| --- | --- |
| `S2S_ROOT` | `D:\s2s` |
| `HF_HOME` | `D:\s2s\cache\huggingface` |
| `HUGGINGFACE_HUB_CACHE` | 同上 `\hub` |

## 竞品与背景

见 [`docs/references/`](docs/references/README.md)。

## 下一步（在 Cursor 中切到本目录后继续）

- [ ] 安装 Python 3.10 + 跑通 `bootstrap.ps1`
- [x] OpenS2S 已复制到 `src/opens2s`（无嵌套 `.git`）
- [ ] 安装 ffmpeg 并加入 PATH
- [ ] 下载 OpenS2S + glm-4-voice-decoder 到 `models/`
- [ ] 在 `docs/` 继续 grill / 写 spike 结论
