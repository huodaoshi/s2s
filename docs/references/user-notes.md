# 我的想法（用户笔记）

**最后更新：** 2026-05-31（收窄为豆包 + 阶跃竞品）

## 帮谁

one-eino / 隐忍型高敏感 AI 小伴——需要**电话式全双工**倾诉，Companion 可控（SafetyGate、倾听式 prompt）。

## 解决什么

找 **原生实时语音大模型**（audio-in → audio-out），**不要** ASR → LLM → TTS 三段级联（如火山 StartVoiceChat + 自定义 LLM）。

## 像什么 / 已知品类

- 对标：**豆包 Seeduplex**（打电话）
- 可接 API：**火山 RealtimeAPI**（SC2.0 陪伴）、**阶跃 StepAudio 2.5 Realtime**
- 品类：full-duplex speech LLM、Speech-to-Speech、Realtime API

## 我还想了解什么

- RealtimeAPI vs StepAudio Realtime：延迟、副语言、人设可控、能否与 SafetyGate 共存
- Seeduplex 何时/是否开放 API
- 是否从 StartVoiceChat 级联迁移到 S2S（及 einoagent 编排怎么接）
