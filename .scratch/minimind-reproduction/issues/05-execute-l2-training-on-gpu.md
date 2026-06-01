Status: ready-for-human

# 在本机 GPU 上执行 L2 训练并人工验收推理

## 要构建什么

在 **M1** 与 mini 数据就绪、安装文档与 **check-l2** 脚本已合并后，于目标机器完成 **L2 — MiniMind reproduction ready** 的运行时部分（非仓库脚本开发）。

按 `src/minimind/SPIKE.md` 在 `trainer/` 下**单卡**依次执行 `train_pretrain.py`、`train_full_sft.py`，产出 `out/pretrain_768.pth` 与 `out/full_sft_768.pth`；运行 `check-l2-minimind.ps1`；再人工执行 `eval_llm.py` 确认中文对话可用。

## 验收标准

- [ ] `.\scripts\check-l2-minimind.ps1` 通过（C1 文件门禁）
- [ ] `eval_llm.py --load_from model --weight full_sft` 交互或固定 prompt 下输出合理中文
- [ ] 训练日志或笔记记录大致耗时与 GPU 型号（供后续 INSTALL 常见问题可选补充）
- [ ] 若训练失败，在 issue Comments 记录错误与已尝试步骤

## 阻塞于

- [04-l2-check-and-install-docs](04-l2-check-and-install-docs.md)

## Comments
