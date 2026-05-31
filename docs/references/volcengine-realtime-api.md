# 参考：火山豆包 RealtimeAPI（端到端实时语音大模型）

**类型：** 直接竞品  
**链接：** https://www.volcengine.com/docs/6561/1594356（API 接入）；https://www.volcengine.com/docs/6561/1594360（产品简介）  
**来源：** Agent 搜索 + 官方文档核实  
**置信度：** 高  
**搜索日期：** 2026-05-31

## 他们解决什么

**豆包端到端实时语音大模型 API（RealtimeAPI）**：WebSocket 直连 **Speech-to-Speech** 模型，语音进、语音出；采用 **Speech2Speech 端到端框架**，非 ASR→LLM→TTS 三段拼装。

与同一厂商 **StartVoiceChat（RTC + 级联 + 自定义 LLM 回调）** 是**不同产品线**。

## 目标用户

情感陪聊 App/硬件、语音助手、智能客服、需要低时延 S2S 的国内开发者。

## 核心功能（与本次想法相关的）

### 接入

- **WebSocket**：`wss://openspeech.bytedance.com/api/v3/realtime/dialogue`
- 鉴权：`X-Api-App-ID`、`X-Api-Access-Key`、`X-Api-Resource-Id: volc.speech.dialog`
- **二进制协议**（header + event + payload）；官方提供 Go/Python/Java 示例

### 模型版本

| 版本 | model 字段示例 | 定位 |
| ---- | -------------- | ---- |
| **O / O2.0** | `1.2.1.1` | 通用助手（客服、车载、闲聊）；精品音色 vv/小何等 |
| **SC / SC2.0** | `2.2.0.0` | **强人格 / 情感陪伴**；克隆音色 + `character_manifest` |

### 交互形态

- 当前文档：**server_vad**（服务端判停，回合式）
- 流程：`StartSession` → `TaskRequest`（20ms PCM/Opus 音频包）→ `ASRInfo/ASRResponse/ASREnded` → `TTSResponse/TTSEnded`
- **打断**：用户再开口时 `ASRInfo`（首字检测）→ 客户端停播；非 Seeduplex 级「边听边说」全双工
- 判停可调：`end_smooth_window_ms`（默认 1500ms）

### 人设与扩展

- O 版：`bot_name`、`system_role`、`speaking_style`；通话中 `UpdateConfig`
- SC 版：`character_manifest` + 官方/自训克隆音色（`ICL_` / `saturn_` / `S_`）
- 上下文：`dialog_id` 最近 20 轮；Conversation CRUD
- **ChatRAGText**（外部 RAG ≤4K）、内置联网搜索、O2.0 唱歌、安全审核 `audit_response`

### 音频

- 上行：PCM 16k mono int16，推荐 20ms/包；或 Opus
- 下行：默认 OGG Opus；可配 PCM 24k

## 定价 / 商业模式

按 [Token 后付费](https://www.volcengine.com/docs/6561/1359370)（无资源包）：

- 输入文本 10 元/百万 token；输入音频 80 元/百万 token
- 输出音频 300 元/百万 token；cached 输入 5 元/百万 token
- 新用户 100 万 token 免费（半年）
- 默认限流：60 QPM、10000 TPM

## 优点

- **国内官方 S2S API**，文档完整，与 one-eino「豆包对标」同生态
- **SC2.0** 明确面向情感陪伴 + 克隆音色
- 副语言、人设、唱歌、RAG/联网能力较全
- 比 OpenAI Realtime 更易满足国内合规与接入

## 缺点 / 局限

- **黑盒 S2S**：无自定义 LLM 回调 → 无法插 **SafetyGate / einoagent RunChat**（one-eino MVP 因此走 StartVoiceChat）
- **server_vad 回合式**，体验上低于 **Seeduplex** 真·全双工
- 无 RTC 房间：弱网/3A 需自建（对比 StartVoiceChat+RTC）
- one-eino 中 `VOLC_REALTIME_*` 环境变量指 **StartVoiceChat OpenAPI**，**不是**本 API 的 WebSocket 凭证

## 与我们的关系

**正面竞争（国内 S2S API 首选候选）** — 若未来接受黑盒 S2S，SC2.0 + character_manifest 最接近 Companion 陪伴场景；当前规格 **刻意不用** 作 MVP 主路径。可与 **SenseVoice SER side-channel** 并行做声学情绪。

## 待核实

- [ ] SC2.0 中文陪伴实测 vs StepAudio / 百度 Realtime
- [ ] 是否计划开放 Seeduplex 级全双工 API 或升级 RealtimeAPI 交互模式
- [ ] 与 einoagent 记忆/checkpoint 的网关 sidecar 形态 PoC 成本
