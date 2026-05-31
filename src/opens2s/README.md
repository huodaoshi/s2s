# OpenS2S spike

上游：https://github.com/CASIA-LM/OpenS2S

## 获取代码

**方式 A — 重新 clone（推荐）**

```powershell
# 在 D:\s2s 根目录，若目录为空：
git clone https://github.com/CASIA-LM/OpenS2S.git .
# 或 clone 到临时目录再移动文件到本目录
```

**方式 B — 从 one-eino 迁移**

若已有 `d:\one-eino\OpenS2S`，可整体复制到 `D:\s2s\src\opens2s`（勿保留嵌套 `.git` 除非作 submodule）。

## 模型权重（放入 `D:\s2s\models\`）

| 组件 | HuggingFace |
| --- | --- |
| OpenS2S | [CASIA-LM/OpenS2S](https://huggingface.co/CASIA-LM/OpenS2S) |
| 流解码器 | [THUDM/glm-4-voice-decoder](https://huggingface.co/THUDM/glm-4-voice-decoder) |

**不能用 LM Studio** 替代 OpenS2S 整包权重（语音解码依赖 LLM hidden states）。

建议路径：

```text
D:\s2s\models\casia-opens2s\
D:\s2s\models\thudm-glm4-voice-decoder\
```

## 依赖

需先 `. .\scripts\env.ps1`，且本机已安装 **ffmpeg**（在 PATH）。

```powershell
pip install -r requirements.txt
```

要求 **torch 2.4.0+cu124**（见上游 `requirements.txt`）；4090 24GB 可试跑 bf16。

## 启动（在上游文档端口约定下）

```powershell
python controller.py
python model_worker.py --model-path D:\s2s\models\casia-opens2s --flow-path D:\s2s\models\thudm-glm4-voice-decoder
python web_demo.py --port 8888
```
