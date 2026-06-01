# MiniMind spike（s2s 工程说明）

上游 README：[`README.md`](./README.md)（[jingyaogong/minimind](https://github.com/jingyaogong/minimind)）

**Vendored upstream** 快照 commit：`4a68da72d5a6c0c8817805b2b627bb935280b12a`（纳入主仓前自嵌套 `.git` 检出；**G1 落地后**删除 `src/minimind/.git`）。

架构与安装决策：[`docs/adr/0002-minimind-spike-installation.md`](../../docs/adr/0002-minimind-spike-installation.md)。术语见 [`CONTEXT.md`](../../CONTEXT.md)。

**M1 / L2 安装**见 [`docs/INSTALL.md`](../../docs/INSTALL.md#minimind-教学复现)。本节假定 **L2 — MiniMind reproduction ready** 已通过验收。

## 数据与权重路径（路径 A）

| 用途 | 路径 |
| --- | --- |
| mini 预训练数据 | `dataset/pretrain_t2t_mini.jsonl` |
| mini SFT 数据 | `dataset/sft_t2t_mini.jsonl` |
| 训练 checkpoint | `out/pretrain_768.pth`、`out/full_sft_768.pth` |

L2 验收不要求 `models/` 下的 HuggingFace 发布权重。

## 训练（L2 复现链）

在 **D:\s2s** 根目录激活 MiniMind 环境后，于本目录执行：

```powershell
. ..\..\scripts\env-minimind.ps1
cd trainer
python train_pretrain.py
python train_full_sft.py
```

默认结构为 **minimind-3** 主线（`hidden_size=768`，8 层）。**L2 默认单卡**；有多卡时可选用：

```powershell
torchrun --nproc_per_node N train_pretrain.py
```

检查点与 `--from_resume 1` 行为见上游 README。

## 推理验证

在 **`src/minimind`** 目录（非 `trainer/`）：

```powershell
python eval_llm.py --load_from model --weight full_sft
```

权重须已位于 `out/full_sft_768.pth`（与 L2 一致）。

## 与 OpenS2S 的边界

- 使用 **`env/.venv-minimind`**，不要用 `env.ps1` / `env/.venv`。
- 本 spike 为文本 LLM 教学复现，**不**替代 OpenS2S 的语音 **L2**。
