# 在 s2s 工程根目录执行： . .\scripts\env-minimind.ps1
$ErrorActionPreference = "Stop"

$S2S_ROOT = Split-Path $PSScriptRoot -Parent

. (Join-Path $PSScriptRoot "mirrors.ps1")

$env:S2S_ROOT = $S2S_ROOT
$env:HF_HOME = Join-Path $S2S_ROOT "cache\huggingface"
$env:HUGGINGFACE_HUB_CACHE = Join-Path $env:HF_HOME "hub"
$env:TRANSFORMERS_CACHE = $env:HUGGINGFACE_HUB_CACHE

$venvActivate = Join-Path $S2S_ROOT "env\.venv-minimind\Scripts\Activate.ps1"
if (Test-Path $venvActivate) {
    . $venvActivate
    Write-Host "[minimind] venv activated: $venvActivate"
} else {
    Write-Host "[minimind] venv not found - run scripts\bootstrap-minimind.ps1 first"
}

if ($env:HF_TOKEN) {
    Write-Host "[minimind] HF_TOKEN is set"
} elseif ($env:HUGGINGFACE_HUB_TOKEN) {
    Write-Host "[minimind] HUGGINGFACE_HUB_TOKEN is set"
}

Write-Host "[minimind] S2S_ROOT=$env:S2S_ROOT"
Write-Host "[minimind] HF_HOME=$env:HF_HOME"
if ($env:HF_ENDPOINT) {
    Write-Host "[minimind] HF_ENDPOINT=$env:HF_ENDPOINT"
}
if ($env:S2S_USE_CN_MIRROR -ne "0") {
    Write-Host "[minimind] pip mirror: $env:S2S_PIP_INDEX"
}
