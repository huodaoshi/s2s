# 在 s2s 工程根目录执行： . .\scripts\env.ps1
$ErrorActionPreference = "Stop"

$S2S_ROOT = Split-Path $PSScriptRoot -Parent

$env:S2S_ROOT = $S2S_ROOT
$env:HF_HOME = Join-Path $S2S_ROOT "cache\huggingface"
$env:HUGGINGFACE_HUB_CACHE = Join-Path $env:HF_HOME "hub"
$env:TRANSFORMERS_CACHE = $env:HUGGINGFACE_HUB_CACHE

$venvActivate = Join-Path $S2S_ROOT "env\.venv\Scripts\Activate.ps1"
if (Test-Path $venvActivate) {
    . $venvActivate
    Write-Host "[s2s] venv activated: $venvActivate"
} else {
    Write-Host "[s2s] venv not found — run scripts\bootstrap.ps1 first"
}

# Optional: HF_TOKEN or HUGGINGFACE_HUB_TOKEN for gated models (see docs/INSTALL.md)
if ($env:HF_TOKEN) {
    Write-Host "[s2s] HF_TOKEN is set"
} elseif ($env:HUGGINGFACE_HUB_TOKEN) {
    Write-Host "[s2s] HUGGINGFACE_HUB_TOKEN is set"
}

Write-Host "[s2s] S2S_ROOT=$env:S2S_ROOT"
Write-Host "[s2s] HF_HOME=$env:HF_HOME"
