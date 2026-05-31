# s2s — 架构

独立 Speech-to-Speech（S2S）spike 与试验工程，与 one-eino 主仓解耦；按 spike 分子目录，共享单一 Python 3.10 虚拟环境。

## 目录结构

```text
D:\s2s\
├── README.md
├── docs/                      # 决策、竞品 references
├── scripts/
│   ├── bootstrap.ps1          # 脚手架 + 创建 env/.venv
│   └── env.ps1                # S2S_ROOT、HF_HOME、激活 venv
├── src/
│   ├── opens2s/               # OpenS2S 上游代码（已复制，无嵌套 .git）
│   │   ├── controller.py      # 分布式 worker 调度
│   │   ├── model_worker.py    # 模型推理 FastAPI worker
│   │   ├── web_demo.py        # Gradio 前端
│   │   ├── flow_inference.py  # glm-4-voice 流式解码
│   │   ├── train.py           # 训练入口
│   │   ├── src/               # OmniSpeech 核心模型
│   │   ├── cosyvoice/         # TTS / flow 子模块
│   │   ├── third_party/       # Matcha-TTS 等
│   │   └── SPIKE.md           # s2s 工程内 spike 说明
│   ├── volc-realtime/         # 火山 RealtimeAPI spike（占位）
│   └── stepfun-realtime/      # 阶跃 StepAudio Realtime spike（占位）
├── env/.venv/                 # Python 3.10 虚拟环境（gitignore）
├── models/                    # HF 权重（gitignore）
├── cache/huggingface/         # HF_HOME（gitignore）
└── logs/
```

## 入口与运行模式

| 组件 | 入口 | 模式 | 默认端口 |
| --- | --- | --- | --- |
| OpenS2S Controller | `src/opens2s/controller.py` | FastAPI + uvicorn | 上游默认 |
| OpenS2S Model Worker | `src/opens2s/model_worker.py` | FastAPI worker，GPU 推理 | 需 `--model-path` / `--flow-path` |
| OpenS2S Web Demo | `src/opens2s/web_demo.py` | Gradio UI | 8888 |
| OpenS2S 训练 | `src/opens2s/train.py` | PyTorch Lightning / DeepSpeed | — |
| 火山 spike | `src/volc-realtime/` | 占位（WebSocket S2S） | 未定 |
| 阶跃 spike | `src/stepfun-realtime/` | 占位（WebSocket S2S） | 未定 |

OpenS2S 典型启动顺序（在 `src/opens2s` 目录）：

1. `python controller.py`
2. `python model_worker.py --model-path <opens2s权重> --flow-path <decoder权重>`
3. `python web_demo.py --port 8888`

## 技术栈与版本

| 项 | 版本 / 说明 |
| --- | --- |
| Python | **3.10**（全工程统一） |
| PyTorch | 2.4.0+cu124 |
| transformers | 4.51.0 |
| FastAPI / uvicorn | 0.110.3 / 0.32.0 |
| Gradio | 4.44.1 |
| PyTorch Lightning | 2.5.1 |

依赖清单：`src/opens2s/requirements.txt`（含 `--extra-index-url` 指向 PyTorch cu124 wheel）。

## 主要外部依赖

| 依赖 | 用途 | 路径 / 来源 |
| --- | --- | --- |
| OpenS2S 权重 | 端到端 S2S 模型 | HuggingFace `CASIA-LM/OpenS2S` → `models/casia-opens2s/` |
| glm-4-voice-decoder | 流式语音解码 | HuggingFace `THUDM/glm-4-voice-decoder` → `models/thudm-glm4-voice-decoder/` |
| ffmpeg | 音频处理 | 系统 PATH（requirements 注释要求） |
| HuggingFace Hub | 权重与缓存 | `HF_HOME` = `cache/huggingface`（`scripts/env.ps1`） |
| 火山 RealtimeAPI | 云 S2S spike | 文档占位，见 `src/volc-realtime/README.md` |
| 阶跃 StepAudio Realtime | 云 S2S spike | 文档占位，见 `src/stepfun-realtime/README.md` |

**注意：** 不能用 LM Studio 替代 OpenS2S 整包权重（语音解码依赖 LLM hidden states）。

## OpenS2S 模型架构（代码层）

`src/opens2s/src/modeling_omnispeech.py` 中 `OmniSpeechModel` 组合：

- **Audio Encoder** — `modeling_audio_encoder.py`
- **LLM backbone** — Qwen3-8B-Instruct（`AutoModelForCausalLM`）
- **TTS LM** — `modeling_tts_lm.py`，自回归 speech token 生成
- **Adapter / Subsampler** — 音频 embedding 对齐 LLM
- **llm2tts** — LLM hidden states → TTS LM

流式解码由 `flow_inference.py`（`AudioDecoder`）与 `cosyvoice/`、`third_party/Matcha-TTS` 支撑。
