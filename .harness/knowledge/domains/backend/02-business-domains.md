# s2s — 业务模块

## Spike 清单

| Spike | 路径 | 状态 | 职责 |
| --- | --- | --- | --- |
| OpenS2S | `src/opens2s/` | **代码已迁入** | 本地开源端到端 empathetic S2S；Controller + Worker + Gradio |
| 火山 RealtimeAPI | `src/volc-realtime/` | 占位 | 豆包 SC2.0 情感陪伴 WebSocket S2S |
| 阶跃 StepAudio Realtime | `src/stepfun-realtime/` | 占位 | StepFun 官方 WebSocket 语音进/出 |

## OpenS2S 模块

### 服务进程（3 个）

| 服务 | 文件 | 职责 |
| --- | --- | --- |
| Controller | `controller.py` | 注册 worker、心跳、按 lottery / shortest_queue 分发请求 |
| Model Worker | `model_worker.py` | 加载 OmniSpeechModel + AudioDecoder，流式生成文本与语音 token |
| Web Demo | `web_demo.py` | Gradio UI，音频/文本输入，调用 controller 转发到 worker |

### 核心 Python 包（`src/opens2s/src/`）

| 模块 | 文件 | 职责 |
| --- | --- | --- |
| OmniSpeech 模型 | `modeling_omnispeech.py` | 端到端 S2S 主模型 |
| 配置 | `configuration_omnispeech.py` | 模型 config 类 |
| 音频编码器 | `modeling_audio_encoder.py` | Audio encoder 映射与实现 |
| TTS LM | `modeling_tts_lm.py` | 自回归 TTS 语言模型 |
| Adapter | `modeling_adapter.py` | Subsampler，音频→LLM 维度 |
| 特征提取 | `feature_extraction_audio.py` | Whisper 风格音频特征 |
| 数据集 | `instruction_dataset.py` | jsonl 指令数据离线/在线处理 |
| 常量 | `constants.py` | token 索引、心跳间隔等 |
| 工具 | `utils.py` | waveform、attention mask 等 |

### 辅助模块

| 模块 | 路径 | 职责 |
| --- | --- | --- |
| 流解码 | `flow_inference.py` | glm-4-voice-decoder 推理 |
| CosyVoice | `cosyvoice/` | flow matching、HiFi-GAN、transformer 等 |
| Matcha-TTS | `third_party/Matcha-TTS/` | 第三方 TTS 依赖 |
| 文本生成工具 | `text_generation.py` | ASR 数据续写构造 |
| 训练脚本 | `train.py`、`scripts/train_*.sh` | 从零训练 / 继续微调 |

## 关键业务流程

### 1. OpenS2S 推理（三进程）

```
用户 → web_demo.py (Gradio)
     → controller.py（选 worker）
     → model_worker.py（OmniSpeech 生成 + AudioDecoder 出波形）
     → 流式返回文本/音频
```

### 2. 环境初始化

```
bootstrap.ps1 → 创建目录 + Python 3.10 venv
env.ps1       → 设置 S2S_ROOT / HF_HOME + 激活 venv
pip install   → src/opens2s/requirements.txt
```

### 3. 云 API spike（待实现）

火山与阶跃 spike 目前仅有 README 与 `docs/references/` 竞品摘要；实现后预期为独立 WebSocket 客户端脚本，共用根级 venv 与 `logs/`。

## 文档与决策

| 文件 | 内容 |
| --- | --- |
| `docs/DECISIONS.md` | 独立工程、Python 3.10、spike 布局等已拍板项 |
| `docs/references/` | 火山 / 阶跃竞品索引 |
| `src/opens2s/SPIKE.md` | OpenS2S 权重路径、依赖、启动命令（s2s 视角） |
