# 参考：阶跃 StepAudio 2.5 Realtime

**类型：** 直接竞品  
**链接：** https://platform.stepfun.com/docs/zh/guides/models/audio  
**来源：** Agent 搜索 + 官方文档核实  
**置信度：** 高  
**搜索日期：** 2026-05-31

## 他们解决什么

**StepAudio 2.5 Realtime**：阶跃 **端到端实时语音大模型**，WebSocket 协议，**语音请求 → 语音回复**；封装好的一整套实时对话能力。

同页 **StepAudio 2.5 Chat** 为按轮次 Chat Completion（语音进、**流式文本出**），**不是** S2S，勿混淆。

## 目标用户

角色扮演、实时语音陪伴、中文/英文对话产品开发者。

## 核心功能（与本次想法相关的）

- **Realtime**：WebSocket，语音进、语音出
- **Chat**：单次语音请求 + 流式文本回复（级联形态，非本次 landscape 主筛）
- 强调 **副语言**（语气、停顿、轻笑）、**千万人设自定义**（性格、口癖、情绪边界）
- 继承 StepAudio 2.5 TTS 的语境表现力（Global 定调 + 句内细节）
- 场景：情感陪伴、日常交流、百科问答、任务助手

## 定价 / 商业模式

见 StepFun 开放平台计费（本次未逐条核实最新价表）。

## 优点

- 国内团队，中文场景与 one-eino 方向贴近
- 官方文档明确 Realtime vs Chat 分工
- 副语言感知与「声学情绪」产品叙事一致

## 缺点 / 局限

- Realtime 接入细节（endpoint、model id、鉴权）需读开发者指南子页
- 全双工程度（是否真 duplex）待 spike 实测
- 企业 SLA、与 SafetyGate 编排需应用层自建

## 与我们的关系

**正面竞争** — 国内原生 S2S 备选；适合与火山 RealtimeAPI、百度 Realtime 做 spike 对比。

## 待核实

- [ ] Realtime WebSocket 接入文档 URL 与 model 枚举
- [ ] 是否 GA、function calling / 工具调用支持
- [ ] 与火山 SC2.0 陪伴场景 A/B 延迟与副语言质量
