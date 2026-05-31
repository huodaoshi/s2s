# s2s

独立 Speech-to-Speech spike 试验工程。与 one-eino 主仓解耦；按 spike 分子目录，共享单一 Python 虚拟环境。

## Language

**Project installation（项目安装）**:
在本仓库内，把环境配置到某一**安装层级**完成态的统称；不是单一步骤，而是分层目标。
_Avoid_: setup、环境搭建（作正式术语时）

**L1 — Development environment ready（开发环境就绪）**:
仓级安装完成态：Python 3.10、`env/.venv`、OpenS2S 依赖已 `pip install`、环境变量（`S2S_ROOT` / `HF_HOME`）已配置；能 `import torch`，**不要求** GPU 权重或 ffmpeg。
_Avoid_: 基础安装、partial install

**L2 — OpenS2S inference ready（OpenS2S 可推理）**:
OpenS2S spike 级安装完成态：在 L1 之上，ffmpeg 可用、**CUDA 可用**（`torch.cuda.is_available()`）、权重已落盘至 **Model artifact directory**、controller / worker / web_demo 三进程可启动并产出语音。
_Avoid_: 完整安装、production ready

**Spike**:
一项可独立验收的技术试验（如 `src/opens2s`、`src/volc-realtime`）；各有自己的 L2 验收标准，但共享 L1。
_Avoid_: 子项目、module

**Model artifact directory（模型权重目录）**:
`models/` 下存放 HuggingFace 权重快照的目录，命名规则为 `<vendor>-<short-name>/`（如 `casia-opens2s`、`thudm-glm4-voice-decoder`）。
_Avoid_: 直接用 HF repo id 作目录名、按 spike 名命名（如 `models/opens2s/`）

## Relationships

- **Project installation** 按层级递进：**L1** 是仓级前提；**L2** 针对具体 **Spike**
- 当前仅 **OpenS2S** spike 定义了 L2；火山 / 阶跃 spike 的 L2 待后续 grill
- 每个 **Model artifact directory** 对应一份 HF 权重；OpenS2S L2 需要两个目录（主模型 + 流解码器）

## Example dialogue

> **Dev:** 「跑完 `bootstrap.ps1` 算安装完成了吗？」
> **Domain expert:** 「若 L1 步骤都跑通，算**开发环境就绪**；要听语音输出，还得完成 OpenS2S 的 **L2**。」

## Flagged ambiguities

- （暂无）
