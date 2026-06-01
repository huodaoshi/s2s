Status: ready-for-human

# 下载 MiniMind mini 训练数据

## 要构建什么

实现 **H1 + D3** 的数据链：`scripts/download-minimind-dataset.ps1` 将 `pretrain_t2t_mini.jsonl` 与 `sft_t2t_mini.jsonl` 放入 **MiniMind dataset directory**（`src/minimind/dataset/`）。

默认 **ModelScope**（`gongjy/minimind_dataset`），失败时回退 **HuggingFace**，镜像探测逻辑与 `download-opens2s-models.ps1` 一致。脚本在 **M1** 环境（`env-minimind`）下运行；可重复执行（已存在则跳过或校验）。

## 验收标准

- [ ] 执行脚本后 `src/minimind/dataset/pretrain_t2t_mini.jsonl` 存在且非空
- [ ] 执行脚本后 `src/minimind/dataset/sft_t2t_mini.jsonl` 存在且非空
- [ ] 脚本在未激活错误 venv 时有明确报错
- [ ] 文档或脚本注释说明 ModelScope / HF 回退与所需环境变量（如 `HF_TOKEN`）

## 阻塞于

- [02-m1-minimind-environment](02-m1-minimind-environment.md)

## Comments

2026-06-01：已实现 — `download-minimind-dataset.ps1`（ModelScope 优先，HF 回退）。
