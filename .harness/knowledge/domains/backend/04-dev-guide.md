# s2s — 开发指南

## 环境准备

```powershell
# 在 D:\s2s 根目录
.\scripts\bootstrap.ps1
. .\scripts\env.ps1
pip install -r src\opens2s\requirements.txt
```

前置条件：

- Python **3.10**（bootstrap 会检测常见安装路径）
- **ffmpeg** 在 PATH
- GPU 环境需匹配 **torch 2.4.0+cu124**

## 验证命令

收工前运行（见 `index.yaml`）：

```powershell
python -m compileall -q src/opens2s
```

完整推理验证需下载权重并手动启动三进程（见 `src/opens2s/SPIKE.md`）。

## 新增 spike 的标准步骤

1. 在 `src/<spike-name>/` 创建子目录与 `README.md`
2. 在 `scripts/bootstrap.ps1` 的 `$dirs` 数组中注册目录（若需脚手架）
3. 在 `docs/references/` 补充竞品摘要（可选）
4. 在 `docs/DECISIONS.md` 记录 grill 结论
5. 结构性变更后运行 **learn** 更新知识库

## OpenS2S 开发约定

- 在 **`src/opens2s`** 目录下启动 controller / worker / web_demo（相对 import 与 `sys.path` 依赖）
- Worker 命令行：`--model-path`、`--flow-path` 指向 `models/` 下本地权重
- 修改模型结构时同步 `src/configuration_omnispeech.py` 与 `modeling_*.py`
- 第三方 vendored 代码在 `third_party/`，尽量避免大范围修改

## 错误处理

- FastAPI 服务统一 `server_error_msg` 字符串提示网络错误
- Worker 使用 `model_semaphore` 控制并发；超载时排队或拒绝
- logging 格式：`%(asctime)s | %(levelname)s | %(name)s | %(message)s`

## 命名约定

| 类别 | 约定 |
| --- | --- |
| spike 目录 | `src/<vendor-or-project>-realtime` 或 `src/opens2s` |
| 模型权重目录 | `models/<vendor>-<model-short-name>/`（建议，待正式拍板） |
| Python 模块 | OpenS2S 上游风格：`src/` 包内相对 import |

## 测试

- 仓库根未配置 pytest / ruff；OpenS2S 上游含少量测试（如 `cosyvoice/flow/stable/stable_diffusion_test.py`）
- `index.yaml` 中 `test_glob: test_*.py`

## 常用调试命令

```powershell
. .\scripts\env.ps1

# 语法检查
python -m compileall -q src/opens2s

# OpenS2S 三进程（需权重，在 src\opens2s 下）
cd src\opens2s
python controller.py
python model_worker.py --model-path D:\s2s\models\casia-opens2s --flow-path D:\s2s\models\thudm-glm4-voice-decoder
python web_demo.py --port 8888
```

## Windows 终端注意

- PowerShell **勿用 `&&`** 连接命令；分号或分行执行
- 激活 venv：`. .\scripts\env.ps1`（点空格点语法）

## Agent 工作流

做功能 / spike 实现前 Read：

- `.harness/workflow/feature-workflow.md`
- `.harness/knowledge/query/s2s.md`
