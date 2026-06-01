# PRD：MiniMind 教学复现（s2s Spike）

**状态：** 范围已由 grill 锁定（2026-06-01）

## 目标

在 s2s 仓库内，以 **MiniMind** spike 完成上游 mini 链路的 **pretrain → SFT** 教学复现（**L2a**），并可被脚本验收至 **M1 / L2** 文件门禁。

## 不做什么

- 不下载官方 `minimind-3` 发布权重冒充训练完成
- 不把 MiniMind 与 OpenS2S 共用 `env/.venv`
- 不把 checkpoint 迁入 `models/` HF 快照约定
- 不在 `check-l2` 中跑推理或评生成质量
- 不要求多卡为 L2 硬性条件（单卡默认）

## 规格来源

- [`CONTEXT.md`](../../CONTEXT.md)
- [`docs/adr/0002-minimind-spike-installation.md`](../../docs/adr/0002-minimind-spike-installation.md)
- [`src/minimind/SPIKE.md`](../../src/minimind/SPIKE.md)

## 成功标准（产品级）

1. 新人可按 `docs/INSTALL.md` MiniMind 章完成 **M1**
2. 数据脚本将 mini jsonl 放入 `src/minimind/dataset/`
3. 单卡跑通 `train_pretrain` + `train_full_sft` 后，`check-l2-minimind.ps1` 通过（C1）
4. 人工 `eval_llm.py` 确认中文对话可用

## Issue 索引

见 [`issues/`](issues/) 目录 `01`–`05`。
