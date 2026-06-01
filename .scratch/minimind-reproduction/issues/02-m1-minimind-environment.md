Status: ready-for-human

# M1：MiniMind 环境脚本（bootstrap / env / check）

## 要构建什么

实现 **B1 + T1 + P1** 的安装链：**M1 — MiniMind environment ready**。

提供 `scripts/bootstrap-minimind.ps1`（创建 `env/.venv-minimind`，显式安装 `torch==2.4.0+cu124` / `torchaudio` 与 cu124 索引，再装 `src/minimind/requirements.txt` 其余依赖）、`scripts/env-minimind.ps1`（激活 venv 并导出本 spike 所需变量，如 `S2S_ROOT` 若训练脚本需要）、`scripts/check-m1-minimind.ps1`（验证 venv、`import torch`、`torch.cuda.is_available()`、关键包如 `transformers`）。

复用现有 `mirrors.ps1` 镜像策略，行为与 OpenS2S `bootstrap.ps1` 对齐。

## 验收标准

- [ ] 在干净环境执行 `.\scripts\bootstrap-minimind.ps1` 成功结束
- [ ] `. .\scripts\env-minimind.ps1` 后 `python -c "import torch; assert torch.cuda.is_available()"` 成功
- [ ] `.\scripts\check-m1-minimind.ps1` 退出码 0 并输出明确 **M1 complete**（或等价文案）
- [ ] 未修改 `env/.venv` 内 OpenS2S 依赖版本

## 阻塞于

- [01-vendor-minimind-into-s2s](01-vendor-minimind-into-s2s.md)

## Comments

2026-06-01：已实现 — `bootstrap-minimind.ps1`、`env-minimind.ps1`、`check-m1-minimind.ps1`。
