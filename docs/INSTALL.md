# 项目安装

术语见根目录 [`CONTEXT.md`](../CONTEXT.md)。安装分两级：

| 层级 | 名称 | 完成态 |
| --- | --- | --- |
| **L1** | Development environment ready | Python 3.10、venv、依赖已装、能 `import torch` |
| **L2** | OpenS2S inference ready | L1 + ffmpeg + CUDA + 权重落盘 + 可启动三进程 |

---

## 前置：Python 3.10（手动）

本工程**不**自动安装系统级 Python。请先安装 3.10 并确认：

```powershell
python3.10 --version
```

示例：

```powershell
choco install python310 -y
```

或 [python.org 3.10.11](https://www.python.org/downloads/release/python-31011/)。

---

## L1 — 开发环境就绪

在仓库根目录：

```powershell
.\scripts\bootstrap.ps1
. .\scripts\env.ps1
```

`bootstrap.ps1` 会：

1. 创建 `env/`、`models/`、`cache/`、`logs/` 等目录
2. 用 Python 3.10 创建 `env/.venv`
3. `pip install -r src/opens2s/requirements.txt`（含 torch 2.4.0+cu124）
4. 校验 `import torch`

成功时输出 **`L1 complete`**。

---

## L2 — OpenS2S 可推理

L1 完成后，按序执行：

### 1. ffmpeg（手动安装）

OpenS2S 依赖 ffmpeg 在 PATH。安装后验证：

```powershell
ffmpeg -version
```

示例：`choco install ffmpeg -y`

### 2. 下载模型权重

**Model artifact directory** 命名：`<vendor>-<short-name>/`

| 目录 | HuggingFace |
| --- | --- |
| `models/casia-opens2s/` | [CASIA-LM/OpenS2S](https://huggingface.co/CASIA-LM/OpenS2S) |
| `models/thudm-glm4-voice-decoder/` | [THUDM/glm-4-voice-decoder](https://huggingface.co/THUDM/glm-4-voice-decoder) |

```powershell
. .\scripts\env.ps1
.\scripts\download-opens2s-models.ps1
```

**认证（gated 模型时）：**

- 优先设置环境变量 `HF_TOKEN` 或 `HUGGINGFACE_HUB_TOKEN`
- 或运行 `huggingface-cli login` 后重试 download 脚本

### 3. L2 验收

```powershell
.\scripts\check-l2-opens2s.ps1
```

检查项：ffmpeg、两个权重目录非空、`torch.cuda.is_available()`。

成功时输出 **`L2 complete`**。

### 4. 启动服务

见 [`src/opens2s/SPIKE.md`](../src/opens2s/SPIKE.md)。

---

## 脚本一览

| 脚本 | 层级 | 作用 |
| --- | --- | --- |
| `scripts/bootstrap.ps1` | L1 | 目录 + venv + pip + torch 校验 |
| `scripts/env.ps1` | — | 环境变量 + 激活 venv（每次开终端） |
| `scripts/download-opens2s-models.ps1` | L2 | 下载 OpenS2S 权重 |
| `scripts/check-l2-opens2s.ps1` | L2 | ffmpeg / 权重 / CUDA 硬门禁 |

---

## 故障排查

| 现象 | 处理 |
| --- | --- |
| `Python 3.10 not found` | 手动安装 3.10 后重跑 bootstrap |
| pip 安装 torch 失败 | 确认网络；requirements 使用 cu124 额外 index |
| download 401 / gated | 设置 `HF_TOKEN` 或 `huggingface-cli login` |
| L2 CUDA fail | 检查 NVIDIA 驱动与 GPU；CPU 推理不在 L2 范围内 |
| worker OOM | 建议 24GB+ VRAM；check 脚本对 &lt;20GB 会 WARN |

---

## 相关文档

- 架构决策：[docs/adr/0001-layered-project-installation.md](./adr/0001-layered-project-installation.md)
- OpenS2S 运行时：[src/opens2s/SPIKE.md](../src/opens2s/SPIKE.md)
