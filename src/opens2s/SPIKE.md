# OpenS2S spike（s2s 工程说明）

上游 README：[`README.md`](./README.md)（CASIA-LM/OpenS2S）

代码来源：自 `one-eino/OpenS2S` 复制，**已去除 `.git`**。

## 模型权重（放入 `D:\s2s\models\`）

| 组件 | HuggingFace |
| --- | --- |
| OpenS2S | [CASIA-LM/OpenS2S](https://huggingface.co/CASIA-LM/OpenS2S) |
| 流解码器 | [THUDM/glm-4-voice-decoder](https://huggingface.co/THUDM/glm-4-voice-decoder) |

**不能用 LM Studio** 替代 OpenS2S 整包权重。

建议路径：

```text
D:\s2s\models\casia-opens2s\
D:\s2s\models\thudm-glm4-voice-decoder\
```

## 依赖与启动

在 **D:\s2s** 根目录：

```powershell
. .\scripts\env.ps1
pip install -r src\opens2s\requirements.txt
```

需 **ffmpeg** 在 PATH；**torch 2.4.0+cu124**。

```powershell
cd src\opens2s
python controller.py
python model_worker.py --model-path D:\s2s\models\casia-opens2s --flow-path D:\s2s\models\thudm-glm4-voice-decoder
python web_demo.py --port 8888
```
