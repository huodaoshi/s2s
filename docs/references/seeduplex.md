# 参考：Seeduplex（字节 Seed）

**类型：** 直接竞品  
**链接：** https://seed.bytedance.com/zh/blog/introducing-seed-full-duplex-speech-llm-attentive-listening-robust-interference-suppression-enabling-more-natural-interaction  
**来源：** Agent 搜索（官方博客 + 媒体报道）  
**置信度：** 中  
**搜索日期：** 2026-05-31

## 他们解决什么

原生**全双工**语音对话：边听边说、动态判停、抗干扰、快速打断——不是回合制 ASR→LLM→TTS。

## 目标用户

C 端豆包用户；情感陪伴 / 实时语音助手场景。

## 核心功能（与本次想法相关的）

- 语音语义**联合建模**，非级联管道
- 持续倾听环境音，忽略旁人/导航等干扰
- 思考留白 vs 说完：声学+语义联合判停
- 用户插话 → 模型收声转听
- 豆包 App「打电话」全量（ reportedly 需桃子音色）

## 定价 / 商业模式

未找到公开开发者 API 计费。C 端免费体验（豆包内）。

## 优点

- 规模化落地（上亿用户级），体验标杆
- 抗干扰、判停、打断有公开 benchmark 数据
- 与 one-eino「对标豆包打电话」体验目标一致

## 缺点 / 局限

- **未见官方对外开放 API**（方舟 MCP 无 Seeduplex 模型；博客仅写 App 体验）
- 项目主页 seed.bytedance.com/seeduplex 访问 500
- 第三方站 seeduplex.io 有 API 文档样式页面 → **非官方**，勿当作真源
- 不可控 Companion 编排（无 SafetyGate 插层）

## 与我们的关系

**体验对标 / 暂不可直接接入** — 产品参照；工程上同生态可接 **[火山 RealtimeAPI](./volcengine-realtime-api.md)**（上一代可开发 S2S），或继续 one-eino **StartVoiceChat 级联**。

## 待核实

- [ ] 火山/Seed 是否有企业内测 API
- [ ] seeduplex.io 是否与字节有关
