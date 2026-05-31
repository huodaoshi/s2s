# s2s — 基础设施与集成

## 环境与路径

| 变量 / 路径 | 设置位置 | 说明 |
| --- | --- | --- |
| `S2S_ROOT` | `scripts/env.ps1` | 仓库根目录 |
| `HF_HOME` | `scripts/env.ps1` | `cache/huggingface` |
| `HUGGINGFACE_HUB_CACHE` | `scripts/env.ps1` | `HF_HOME/hub` |
| `TRANSFORMERS_CACHE` | `scripts/env.ps1` | 同 HUB cache |
| venv | `env/.venv` | bootstrap 用 Python 3.10 创建 |

权重与缓存目录在 `.gitignore` 中排除，不进 git。

## 建议模型目录布局

```text
models/
├── casia-opens2s/           # CASIA-LM/OpenS2S
└── thudm-glm4-voice-decoder/  # THUDM/glm-4-voice-decoder
```

命名规范仍在 grill 中（`docs/DECISIONS.md` 待办）。

## OpenS2S 分布式 worker 模式

沿用 FastChat 风格三进程架构：

- **Controller** — worker 注册表、心跳过期清理（`CONTROLLER_HEART_BEAT_EXPIRATION`）
- **Worker** — 定期心跳（`WORKER_HEART_BEAT_INTERVAL`）、信号量限流、`TokenStreamer` 流式输出
- **Dispatch** — `lottery` 或 `shortest_queue`

Worker 启动时需 GPU 与足够显存（4090 24GB 可试 bf16，见 SPIKE.md）。

## 日志

- OpenS2S 进程使用标准 logging，级别由环境变量 `LOGLEVEL` 控制（默认 INFO）
- 根级 `logs/` 目录由 bootstrap 创建；各 spike 默认端口与 `logs/` 文件约定**尚未拍板**（见 DECISIONS.md）

## 第三方集成

| 集成 | 类型 | 状态 |
| --- | --- | --- |
| HuggingFace Hub | 模型下载与缓存 | 已配置环境变量 |
| PyTorch CUDA 12.4 | GPU 推理 | requirements 固定 cu124 wheel |
| ffmpeg | 音频编解码 | 需系统 PATH，未脚本化 |
| 火山 RealtimeAPI WebSocket | 云 S2S | 占位 |
| 阶跃 StepAudio Realtime WebSocket | 云 S2S | 占位 |

## 无以下基础设施

本工程当前**不使用**：关系型数据库、Redis、消息队列、配置中心。状态均在进程内存（controller worker 表）或本地文件（模型权重、HF cache）。

## DeepSpeed / 训练

- `src/opens2s/ds_config/dp_config_zero1.json`、`dp_config_zero2.json` — DeepSpeed ZeRO 配置
- 训练数据格式：jsonl，每行含 `messages` 键（见上游 README）
- 离线预处理：`python src/instruction_dataset.py offline ...`
