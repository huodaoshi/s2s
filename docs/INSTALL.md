# 项目安装

术语见根目录 [`CONTEXT.md`](../CONTEXT.md)。安装分两级：

| 层级 | 名称 | 完成态 |
| --- | --- | --- |
| **L1** | Development environment ready（OpenS2S） | Python 3.10、`env/.venv`、依赖已装、能 `import torch` |
| **L2** | OpenS2S inference ready | L1 + ffmpeg + CUDA + 权重落盘 + 可启动三进程 |
| **M1** | MiniMind environment ready | Python 3.10、`env/.venv-minimind`、MiniMind 依赖、CUDA 可用 |
| **L2** | MiniMind reproduction ready | M1 + mini 数据 + 本机训练 checkpoint + 人工 `eval_llm` |

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

## 国内镜像（默认开启）

`scripts/mirrors.ps1` 在 **未禁用** 时自动使用：

| 用途 | 默认镜像 |
| --- | --- |
| PyPI | `https://pypi.tuna.tsinghua.edu.cn/simple` |
| PyTorch cu124 | `https://download.pytorch.org/whl/cu124`（**+cu124 仅官方源**，约 2.5GB） |
| HuggingFace 权重 | 默认 `https://hf-mirror.com`（`download-opens2s-models.ps1` 用 `HfApi` 下载；不可达时自动探测官方源） |

`bootstrap.ps1`、`env.ps1`、`download-opens2s-models.ps1` 均会加载上述配置。

**禁用国内镜像**（走官方源）：

```powershell
$env:S2S_USE_CN_MIRROR = "0"
.\scripts\bootstrap.ps1
```

**自定义镜像**（在运行 bootstrap 前设置）：

```powershell
$env:S2S_PIP_INDEX = "https://mirrors.aliyun.com/pypi/simple/"
$env:S2S_PYTORCH_INDEX = "https://mirrors.tuna.tsinghua.edu.cn/pytorch-wheels/cu124"
$env:HF_ENDPOINT = "https://hf-mirror.com"
```

若当前 L1 安装很慢，可 **Ctrl+C 中断** 后删除半成品 venv 并重跑（镜像对未完成的 pip 更有效）：

```powershell
Remove-Item -Recurse -Force env\.venv
.\scripts\bootstrap.ps1
```

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

## MiniMind 教学复现 {#minimind-教学复现}

术语与架构见 [`CONTEXT.md`](../CONTEXT.md)、[`docs/adr/0002-minimind-spike-installation.md`](./adr/0002-minimind-spike-installation.md)。**不**使用 OpenS2S 的 `env.ps1` / `env/.venv`。

### M1 — MiniMind 环境就绪

在仓库根目录：

```powershell
.\scripts\bootstrap-minimind.ps1
. .\scripts\env-minimind.ps1
.\scripts\check-m1-minimind.ps1
```

`bootstrap-minimind.ps1` 会创建 `env/.venv-minimind`，先安装与 OpenS2S L1 对齐的 `torch==2.4.0+cu124`，再安装 `src/minimind/requirements.txt` 其余包。

成功时 **`M1 complete`**。**CUDA 为硬性要求**（训练与 M1 验收）。

### 下载 mini 训练数据

```powershell
. .\scripts\env-minimind.ps1
.\scripts\download-minimind-dataset.ps1
```

默认 **ModelScope**（`gongjy/minimind_dataset`），失败时回退 **HuggingFace**（`jingyaogong/minimind_dataset`）。目标路径：

| 文件 | 路径 |
| --- | --- |
| `pretrain_t2t_mini.jsonl` | `src/minimind/dataset/` |
| `sft_t2t_mini.jsonl` | `src/minimind/dataset/` |

HF 需认证时：设置 `HF_TOKEN` 或 `huggingface-cli login`。

### L2 — MiniMind 可复现（训练 + 文件门禁）

1. **单卡**（默认）在 `src/minimind/trainer/` 依次训练：

```powershell
. ..\..\scripts\env-minimind.ps1
cd src\minimind\trainer
python train_pretrain.py
python train_full_sft.py
```

产出 `src/minimind/out/pretrain_768.pth`、`full_sft_768.pth`。

2. 文件门禁（**不**跑推理）：

```powershell
.\scripts\check-l2-minimind.ps1
```

3. **人工**推理验收（在 `src/minimind`）：

```powershell
python eval_llm.py --load_from model --weight full_sft
```

训练细节与多卡可选命令见 [`src/minimind/SPIKE.md`](../src/minimind/SPIKE.md)。

---

## 脚本一览

| 脚本 | 层级 | 作用 |
| --- | --- | --- |
| `scripts/bootstrap.ps1` | L1 | 目录 + venv + pip + torch 校验 |
| `scripts/env.ps1` | — | 环境变量 + 激活 venv（每次开终端） |
| `scripts/download-opens2s-models.ps1` | L2 | 下载 OpenS2S 权重 |
| `scripts/check-l2-opens2s.ps1` | L2 | ffmpeg / 权重 / CUDA 硬门禁 |
| `scripts/bootstrap-minimind.ps1` | M1 | MiniMind venv + pip + torch 校验 |
| `scripts/env-minimind.ps1` | — | 激活 `env/.venv-minimind` |
| `scripts/check-m1-minimind.ps1` | M1 | MiniMind venv / CUDA / transformers |
| `scripts/download-minimind-dataset.ps1` | L2 前 | mini jsonl → `src/minimind/dataset/` |
| `scripts/check-l2-minimind.ps1` | L2 | 数据 + `out/*.pth` 文件门禁（C1） |

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
- MiniMind 决策：[docs/adr/0002-minimind-spike-installation.md](./adr/0002-minimind-spike-installation.md)
- MiniMind 训练/推理：[src/minimind/SPIKE.md](../src/minimind/SPIKE.md)
