# s2s

独立 Speech-to-Speech spike 试验工程。与 one-eino 主仓解耦；按 spike 分子目录。OpenS2S 与部分 spike 共用 `env/.venv`；**MiniMind** 使用独立虚拟环境 `env/.venv-minimind`。

## Language

**Project installation（项目安装）**:
在本仓库内，把环境配置到某一**安装层级**完成态的统称；不是单一步骤，而是分层目标。
_Avoid_: setup、环境搭建（作正式术语时）

**L1 — Development environment ready（开发环境就绪）**:
仓级安装完成态（OpenS2S 向）：Python 3.10、`env/.venv`、OpenS2S 依赖已 `pip install`、环境变量（`S2S_ROOT` / `HF_HOME`）已配置；能 `import torch`，**不要求** GPU 权重或 ffmpeg。
_Avoid_: 基础安装、partial install、把 **M1** 称作 L1

**M1 — MiniMind environment ready（MiniMind 环境就绪）**:
MiniMind spike 级环境完成态：Python 3.10、`env/.venv-minimind` 已创建、`src/minimind/requirements.txt` 已安装、能 `import torch` 且 **CUDA 可用**；**不要求** 训练数据或 **Training checkpoint**。
_Avoid_: 把 M1 与 **L2 — MiniMind reproduction ready** 混为一谈、在 `env/.venv` 里装 MiniMind 依赖

**L2 — OpenS2S inference ready（OpenS2S 可推理）**:
OpenS2S spike 级安装完成态：在 L1 之上，ffmpeg 可用、**CUDA 可用**（`torch.cuda.is_available()`）、权重已落盘至 **Model artifact directory**、controller / worker / web_demo 三进程可启动并产出语音。
_Avoid_: 完整安装、production ready

**L2 — MiniMind reproduction ready（MiniMind 可复现）**:
MiniMind spike 级完成态：在 **M1** 之上，mini 训练数据已就位、`train_pretrain` 与 `train_full_sft` 在本机从头跑通，`src/minimind/out/` 存在 `pretrain_768.pth` 与 `full_sft_768.pth`，`eval_llm.py` 可稳定中文对话。
_Avoid_: 下载官方发布权重冒充训练完成、把 MiniMind L2 与 OpenS2S L2 混称「L2 完成」

**Spike**:
一项可独立验收的技术试验（如 `src/opens2s`、`src/minimind`、`src/volc-realtime`）；各有自己的 L2 验收标准，但共享 L1。
_Avoid_: 子项目、module

**MiniMind**:
文本 LLM 教学复现 spike；上游训练代码位于 `src/minimind/`（**vendored upstream**，无嵌套 `.git`），目标为跑通上游 mini 数据链路的 pretrain → SFT。
_Avoid_: 把 MiniMind 与 OpenS2S 混为同一 spike、用上游模型名 `minimind-3` 指代本 spike、对 MiniMind 使用 git submodule

**Vendored upstream（纳入主仓的上游快照）**:
去掉嵌套 `.git` 后由 s2s 主仓跟踪的 spike 源代码树（如 `src/opens2s`、`src/minimind`）。
_Avoid_: 子模块、在 spike 目录内保留独立 `.git` 仍称已纳入主仓

**MiniMind environment（MiniMind 环境）**:
MiniMind spike 专用 Python 虚拟环境，路径为 `env/.venv-minimind`；由 **`bootstrap-minimind`** 创建、由 **`env-minimind`** 激活；依赖以 `src/minimind/requirements.txt` 为准，与 OpenS2S 的 `env/.venv` 隔离。
_Avoid_: 在 `env/.venv` 里混装 MiniMind 依赖、把 MiniMind 环境称作 L1、用 `bootstrap.ps1` 代指 MiniMind 环境搭建

**bootstrap-minimind**:
创建并配置 **MiniMind environment** 的仓库脚本入口（`scripts/bootstrap-minimind.ps1`）。
_Avoid_: 与 OpenS2S 的 `bootstrap.ps1` 混称「bootstrap」

**env-minimind**:
激活 **MiniMind environment** 并导出本 spike 所需环境变量的脚本入口（`scripts/env-minimind.ps1`）。
_Avoid_: 用 `env.ps1` 激活 MiniMind venv

**Model artifact directory（模型权重目录）**:
`models/` 下存放 HuggingFace 权重快照的目录，命名规则为 `<vendor>-<short-name>/`（如 `casia-opens2s`、`thudm-glm4-voice-decoder`）。
_Avoid_: 直接用 HF repo id 作目录名、按 spike 名命名（如 `models/opens2s/`）

**Training checkpoint（训练检查点）**:
MiniMind spike 内 PyTorch 训练产出（`*.pth`），默认目录为 `src/minimind/out/`；与 **Model artifact directory** 中的 HF 快照不是同一类产物。
_Avoid_: 把 `out/*.pth` 称为模型权重目录、要求放进 `models/`

**MiniMind dataset directory（MiniMind 数据目录）**:
MiniMind 训练用 jsonl 数据目录，路径为 `src/minimind/dataset/`。
_Avoid_: 与 `cache/huggingface/` 混称

**Dataset download script（数据下载脚本）**:
仓库 `scripts/` 下、将 MiniMind mini 训练数据放入 **MiniMind dataset directory** 的自动化入口。
_Avoid_: 仅靠上游 README 外链手动下载作为唯一正式路径

**Installation check script（安装检查脚本）**:
仓库 `scripts/` 下、判定 **M1** 或 **L2 — MiniMind reproduction ready** 是否达成的检查入口；MiniMind 的 L2 检查为**文件门禁**（数据与 checkpoint），不替代人工推理验收。
_Avoid_: 与 OpenS2S 的 `check-l2-opens2s` 混为同一脚本、用检查脚本判定生成质量

## Relationships

- **Project installation** 按层级递进：**L1** 是仓级前提；**L2** 针对具体 **Spike**
- 当前 **OpenS2S** 与 **MiniMind** 已各自定义 L2；火山、阶跃 spike 的 L2 待后续 grill
- **MiniMind** 与 **OpenS2S** 验收独立；完成其一的 L2 不蕴含另一 spike 的 L2
- **MiniMind** 与 **OpenS2S** 均为 **Vendored upstream**
- **Project installation** 对 MiniMind：**M1** → **L2**（与 OpenS2S 的 **L1** → **L2** 并列，层级编号不共用）
- **L1** 与 **M1** 相互独立；完成其一不蕴含另一 spike 的环境或验收
- 每个 **Model artifact directory** 对应一份 HF 权重；OpenS2S L2 需要两个目录（主模型 + 流解码器）
- **MiniMind** L2 依赖 **MiniMind dataset directory** 与 **Training checkpoint**，不依赖 **Model artifact directory**
- **MiniMind** 的 **M1** / **L2** 通过 **Installation check script** 验收；**L2** 前由 **Dataset download script** 准备 mini 数据

## Example dialogue

> **Dev:** 「跑完 `bootstrap.ps1` 算安装完成了吗？」
> **Domain expert:** 「若 L1 步骤都跑通，算**开发环境就绪**（OpenS2S 向）；要听语音输出，还得完成 OpenS2S 的 **L2**。」
>
> **Dev:** 「我只想训 MiniMind，也要先 L1 吗？」
> **Domain expert:** 「不必。走 **M1**（`env/.venv-minimind`）再 **L2**；和 OpenS2S 的 L1 无关。」

## Flagged ambiguities

- （暂无）
