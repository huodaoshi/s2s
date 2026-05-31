---
status: accepted
---

# 分层项目安装（L1 / L2）

本仓库将「项目安装」分为仓级 **L1（开发环境就绪）** 与 spike 级 **L2（OpenS2S 可推理）**。L1 由 `bootstrap.ps1` 一次性完成（含 pip 与 torch 校验）；L2 拆为权重下载脚本与验收脚本，ffmpeg 与 Python 3.10 仍由用户手动安装。

## Considered Options

- **一步到位**：bootstrap 同时装 ffmpeg、下权重、验 GPU — 拒绝：系统级依赖侵入大，权重体积与 L1 目标无关。
- **纯文档、无脚本** — 拒绝：OpenS2S 权重路径与 HF repo 易写错，新人漏 `pip install`。
- **L2 软警告 GPU** — 拒绝：L2 定义即「能推理」；无 CUDA 不应标为 L2 完成。

## Consequences

- `README` 只保留 L1 入口；全流程见 `docs/INSTALL.md`。
- 火山 / 阶跃 spike 将来各自定义 L2 脚本（如 `check-l2-volc-realtime.ps1`），共享 L1。
