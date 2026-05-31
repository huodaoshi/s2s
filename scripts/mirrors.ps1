# 国内/自定义镜像（bootstrap.ps1、env.ps1、download-opens2s-models.ps1 共用）
# 禁用国内镜像：$env:S2S_USE_CN_MIRROR = "0"

if ($env:S2S_USE_CN_MIRROR -eq "0") {
    return
}

if (-not $env:S2S_PIP_INDEX) {
    $env:S2S_PIP_INDEX = "https://pypi.tuna.tsinghua.edu.cn/simple"
}
# +cu124 wheels only on download.pytorch.org; always override stale env
$env:S2S_PYTORCH_INDEX = "https://download.pytorch.org/whl/cu124"
if (-not $env:HF_ENDPOINT) {
    # download-opens2s-models.ps1 uses HfApi(endpoint=...) + auto probe; default mirror for CN.
    $env:HF_ENDPOINT = "https://hf-mirror.com"
}
