# 决策记录（grill 暂停点）

**日期：** 2026-05-31

## 已共识

1. **独立工程**：`D:\s2s`，不依赖 one-eino 仓库结构；工作区切换到本目录后再继续讨论。
2. **Git**：从第一天起为独立 Git 仓库。
3. **目录布局（C）**：按 spike 分子目录，共享 `env/.venv`。
4. **Python 3.10**：全工程统一（OpenS2S 优先）。

## 待在本工程内继续 grill

- [ ] `models/` 命名规范（按厂商 vs 按模型 id）
- [ ] OpenS2S 从 `one-eino/OpenS2S` **迁移**还是 **重新 clone**
- [ ] ffmpeg / CUDA PyTorch 安装责任（脚本 vs 文档）
- [ ] 各 spike 默认端口与 `logs/` 约定
- [ ] spike 结论如何回流 one-eino（ADR / `.scratch` / 口头）
