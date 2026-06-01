# 决策记录（grill 暂停点）

**日期：** 2026-05-31（MiniMind grill 更新：2026-06-01）

## 已共识

1. **独立工程**：`D:\s2s`，不依赖 one-eino 仓库结构；工作区切换到本目录后再继续讨论。
2. **Git**：从第一天起为独立 Git 仓库。
3. **目录布局（C）**：按 spike 分子目录；OpenS2S 用 `env/.venv`，MiniMind 用 `env/.venv-minimind`（见 ADR-0002）。
4. **Python 3.10**：全工程统一（OpenS2S 优先）；**手动安装**，bootstrap 只检测。
5. **分层安装（L1/L2）**：见 [`docs/adr/0001-layered-project-installation.md`](adr/0001-layered-project-installation.md) 与 [`docs/INSTALL.md`](INSTALL.md)。
6. **L1**：`bootstrap.ps1` = 目录 + venv + `pip install` + torch 校验。
7. **L2 OpenS2S**：`download-opens2s-models.ps1` + `check-l2-opens2s.ps1`；ffmpeg 手动；CUDA 硬门禁。
8. **models/ 命名**：厂商-简称（`casia-opens2s`、`thudm-glm4-voice-decoder`）。
9. **HF 认证**：优先 `HF_TOKEN`；失败时指引 `huggingface-cli login`。
10. **安装文档分层**：README 概要 → `docs/INSTALL.md` → `src/opens2s/SPIKE.md` 运行时。
11. **OpenS2S 从 one-eino 复制**到 `src/opens2s`（已去除 `.git`）。
12. **MiniMind spike**（2026-06-01 grill）：教学复现（A）、正式 Spike（Y）、独立 venv + M1/L2（B/P1/L2a）、路径 A、vendored G1、脚本 D3/B1；见 [`docs/adr/0002-minimind-spike-installation.md`](adr/0002-minimind-spike-installation.md) 与 [`CONTEXT.md`](../CONTEXT.md)。

## 待在本工程内继续 grill

- [ ] 各 spike 默认端口与 `logs/` 约定
- [ ] spike 结论如何回流 one-eino（ADR / `.scratch` / 口头）
- [x] MiniMind 脚本与文档（01–04）：bootstrap / env / download / check-m1/l2、`INSTALL.md`、G1 去 `.git`
- [ ] MiniMind L2 训练执行（issue 05，需本机 GPU）
