# 竞品与参考品索引

**feature：** realtime-native-speech-llm  
**扫描日期：** 2026-05-31  
**范围（用户收窄）：** 仅 **豆包/火山（字节）** 与 **阶跃 StepFun** 原生实时语音大模型

## 怎么用

供 `product-council` 或人工阅读。Agent 搜索内容标置信度，决策前请核实官方文档与定价。

## 清单

| 类型 | 名称 | 文件 | 置信度 | 一句话 |
| ---- | ---- | ---- | ------ | ------ |
| 直接竞品 | 火山豆包 RealtimeAPI | [volcengine-realtime-api.md](./volcengine-realtime-api.md) | 高 | 国内官方 S2S WebSocket；O/SC 双系列，SC2.0 情感陪伴 + 克隆音色 |
| 直接竞品 | Seeduplex（字节 Seed） | [seeduplex.md](./seeduplex.md) | 中 | 豆包「打电话」体验标杆，原生全双工；**公开开发者 API 未见官方文档** |
| 直接竞品 | 阶跃 StepAudio 2.5 Realtime | [stepfun-stepaudio-realtime.md](./stepfun-stepaudio-realtime.md) | 高 | 官方 WebSocket Realtime；副语言、人设定制；与 Chat（文本回）区分 |

## 豆包侧关系（简图）

```
Seeduplex（App 内全双工，体验对标）
    ↑ 下一代体验
RealtimeAPI（开发者可接 S2S WebSocket）
    ↑ 非级联
StartVoiceChat（one-eino MVP：RTC + ASR→LLM→TTS 级联）← 刻意未纳入本清单
```

## 刻意未纳入

| 名称 | 原因 |
| ---- | ---- |
| 火山 StartVoiceChat + 自定义 LLM | **ASR→LLM→TTS 级联**（one-eino MVP 当前路径） |
| OpenAI / Gemini / 百度 / Amazon / Moshi / MiniCPM 等 | 用户收窄范围，已删文件 |
| seeduplex.io 第三方 API 文档站 | **非字节官方域名** |

## 待补充

- [ ] StepAudio Realtime WebSocket 接入子文档（endpoint、model id）
- [ ] Seeduplex 是否独立开放开发者 API（相对 RealtimeAPI）
- [ ] 火山 SC2.0 vs StepAudio 2.5 Realtime 陪伴场景 spike 对比
