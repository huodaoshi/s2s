# OpenS2S spike（s2s 工程说明）

上游 README：[`README.md`](./README.md)（CASIA-LM/OpenS2S）

代码来源：自 `one-eino/OpenS2S` 复制，**已去除 `.git`**。

**安装（L1/L2）**见 [`docs/INSTALL.md`](../../docs/INSTALL.md)。本节仅 **L2 验收通过后的运行时**。

## Model artifact directories

| 目录 | HuggingFace |
| --- | --- |
| `models/casia-opens2s/` | [CASIA-LM/OpenS2S](https://huggingface.co/CASIA-LM/OpenS2S) |
| `models/thudm-glm4-voice-decoder/` | [THUDM/glm-4-voice-decoder](https://huggingface.co/THUDM/glm-4-voice-decoder) |

**不能用 LM Studio** 替代 OpenS2S 整包权重。

下载与 L2 验收：

```powershell
# 在 D:\s2s 根目录，L1 已完成
.\scripts\download-opens2s-models.ps1
.\scripts\check-l2-opens2s.ps1
```

## 启动三进程

在 **D:\s2s** 根目录先激活环境：

```powershell
. .\scripts\env.ps1
```

在 **`src/opens2s`** 目录启动（相对 import 依赖此 cwd）：

```powershell
cd src\opens2s
python controller.py
python model_worker.py --model-path D:\s2s\models\casia-opens2s --flow-path D:\s2s\models\thudm-glm4-voice-decoder
python web_demo.py --port 8888
```

默认 Web Demo 端口：**8888**（各 spike 端口统一约定仍待 grill）。
