---
status: accepted
---

# MiniMind spike 安装与仓库集成

本仓库将 **MiniMind** 作为与 OpenS2S 并列的文本 LLM 教学复现 **Spike**。目标为在本机跑通上游 mini 数据链路的 pretrain → SFT（**L2a**），而非下载官方发布权重冒充训练完成。OpenS2S 继续使用 `env/.venv` 与 **L1 → L2**；MiniMind 使用独立虚拟环境 **M1 → L2**，层级编号不共用。

## 已决事项

- **源代码**：`src/minimind/` 以 **vendored upstream** 纳入主仓（**G1**），去除嵌套 `.git`，不使用 submodule。
- **环境**：`env/.venv-minimind`（**B1**），由 `scripts/bootstrap-minimind.ps1` 创建、`scripts/env-minimind.ps1` 激活；不在 `env/.venv` 混装 MiniMind 依赖（`transformers` 等与 OpenS2S 版本冲突）。
- **PyTorch（T1）**：`bootstrap-minimind` 与 OpenS2S L1 对齐，显式安装 `torch==2.4.0+cu124` / `torchaudio`（cu124 索引），再安装 `src/minimind/requirements.txt` 其余项。
- **M1**：venv 存在、MiniMind 依赖已装、`torch` 可 import 且 **CUDA 可用**；不要求训练数据或 checkpoint。
- **L2**：在 M1 之上，mini jsonl 就位、`train_pretrain` + `train_full_sft` 从头跑通，`src/minimind/out/` 含 `pretrain_768.pth` 与 `full_sft_768.pth`；**人工**确认 `eval_llm.py` 可对话。**L2 检查脚本（C1）** 仅做文件门禁（数据 + checkpoint 存在且非空），不跑推理。
- **路径（A）**：数据 `src/minimind/dataset/`；checkpoint `src/minimind/out/`；不纳入 `models/` 的 HF 快照命名约定。
- **脚本（D3 + B1）**：`download-minimind-dataset.ps1`、`check-m1-minimind.ps1`、`check-l2-minimind.ps1`（命名与 OpenS2S 对称，待实现）。
- **数据下载（H1）**：`download-minimind-dataset.ps1` 默认 **ModelScope**（`gongjy/minimind_dataset`），失败时回退 **HuggingFace**；仅拉取 `pretrain_t2t_mini.jsonl` 与 `sft_t2t_mini.jsonl` 至 **MiniMind dataset directory**。
- **算力（G0）**：L2 文档与验收默认 **单卡**；多卡 `torchrun` 为可选加速，非 L2 硬性要求。

## Considered Options

- **共用 `env/.venv` 并升级 transformers** — 拒绝：OpenS2S 钉死 `4.51.0`，MiniMind 需 `4.57.6`，回归风险高。
- **git submodule 跟踪上游** — 拒绝：与 OpenS2S vendored 模式不一致，Agent 单仓导航成本高。
- **checkpoint 迁入 `models/minimind-*`** — 拒绝：`.pth` 与 HF 快照生命周期不同，改动上游默认路径收益小。
- **L2c 仅推理 / L2d 全量数据** — 拒绝：与教学复现目标 A 及单机算力预期不符。
- **扩展 L1 覆盖双 venv** — 拒绝：稀释现有 L1（OpenS2S 向）语义；采用独立 **M1**。

## Consequences

- 术语与关系见根目录 [`CONTEXT.md`](../../CONTEXT.md)。
- `docs/INSTALL.md` 需增 MiniMind 章节（M1 / L2 / 脚本），与 OpenS2S 分节。
- `docs/adr/0001` 中「各 spike 共享 L1」的表述仅适用于 OpenS2S 向；MiniMind 读者应查阅本 ADR 与 **M1**。
- 运行时与训练操作见 [`src/minimind/SPIKE.md`](../../src/minimind/SPIKE.md)（**S1**）。
- 实现待办：`docs/INSTALL.md` MiniMind 章、bootstrap/check/download 脚本、G1 落地（删除 `src/minimind/.git`）、`.gitignore` 补充 `env/.venv-minimind/`。
