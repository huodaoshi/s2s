Status: ready-for-human

# L2 文件门禁脚本与 INSTALL 文档

## 要构建什么

实现 **C1 + D3** 的 L2 验收入口与安装叙事闭环。

1. `scripts/check-l2-minimind.ps1`：检查 mini jsonl 与 `src/minimind/out/pretrain_768.pth`、`full_sft_768.pth` 存在且非空；**不**运行 `eval_llm.py`。
2. 在 `docs/INSTALL.md` 增加 **MiniMind** 专章：M1 → 下载数据 → 训练（单卡默认，**G0**）→ check-l2 → 人工 eval；链接 ADR-0002、`SPIKE.md`。
3. 核对 `src/minimind/SPIKE.md` 中脚本名、`env-minimind` 路径与实现一致。

## 验收标准

- [ ] 在仅有数据、无 checkpoint 时 `check-l2-minimind.ps1` 失败且信息可定位缺什么
- [ ] 在占位非空 `.pth` 与真实 jsonl 存在时 `check-l2-minimind.ps1` 退出码 0（可用临时文件做本地自测，勿提交权重）
- [ ] `docs/INSTALL.md` MiniMind 章逐步引用真实脚本名
- [ ] `README.md` 含一行指向 MiniMind 安装（或 INSTALL 锚点），不重复全文

## 阻塞于

- [02-m1-minimind-environment](02-m1-minimind-environment.md)
- [03-download-minimind-mini-dataset](03-download-minimind-mini-dataset.md)

## Comments

2026-06-01：已实现 — `check-l2-minimind.ps1`；`docs/INSTALL.md` MiniMind 章；`README.md` 索引。
