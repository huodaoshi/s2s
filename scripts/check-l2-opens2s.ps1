# 在 s2s 工程根目录执行： .\scripts\check-l2-opens2s.ps1
# OpenS2S L2 — OpenS2S inference ready 验收
$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

$failed = $false

function Fail-Check {
    param([string]$Message)
    Write-Host "FAIL: $Message" -ForegroundColor Red
    $script:failed = $true
}

function Pass-Check {
    param([string]$Message)
    Write-Host "OK:   $Message" -ForegroundColor Green
}

Write-Host "OpenS2S L2 checks"
Write-Host "================="
Write-Host ""

# ffmpeg
if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
    $ff = ffmpeg -version 2>&1 | Select-Object -First 1
    Pass-Check "ffmpeg in PATH ($ff)"
} else {
    Fail-Check "ffmpeg not found in PATH"
    Write-Host "      Install manually, e.g.: choco install ffmpeg -y"
    Write-Host "      Or: https://ffmpeg.org/download.html"
}

# Model artifact directories
$modelDirs = @(
    "models\casia-opens2s",
    "models\thudm-glm4-voice-decoder"
)
foreach ($rel in $modelDirs) {
    $p = Join-Path $Root $rel
    if ((Test-Path $p) -and ((Get-ChildItem $p -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0)) {
        Pass-Check "$rel exists and is non-empty"
    } else {
        Fail-Check "$rel missing or empty"
        Write-Host "      Run: .\scripts\download-opens2s-models.ps1"
    }
}

# CUDA (requires venv)
$venvPython = Join-Path $Root "env\.venv\Scripts\python.exe"
if (-not (Test-Path $venvPython)) {
    Fail-Check "venv not found — run .\scripts\bootstrap.ps1 first"
} else {
    $cudaScript = @'
import sys
import torch
if not torch.cuda.is_available():
    print("CUDA_NOT_AVAILABLE")
    sys.exit(1)
name = torch.cuda.get_device_name(0)
total_gb = torch.cuda.get_device_properties(0).total_memory / (1024**3)
print(f"CUDA_OK|{name}|{total_gb:.1f}")
'@
    $result = & $venvPython -c $cudaScript 2>&1
    if ($LASTEXITCODE -ne 0 -or ($result -match "CUDA_NOT_AVAILABLE")) {
        Fail-Check "torch.cuda.is_available() is False"
        Write-Host "      Check NVIDIA driver and CUDA-compatible GPU."
    } else {
        $parts = ($result -split "\|")
        Pass-Check ("CUDA available — " + $parts[1] + ", " + $parts[2] + " GB VRAM")
        $vram = [double]$parts[2]
        if ($vram -lt 20) {
            Write-Host "WARN: OpenS2S bf16 typically needs ~24 GB VRAM; you may OOM at runtime." -ForegroundColor Yellow
        }
    }
}

Write-Host ""
if ($failed) {
    Write-Host "L2 NOT ready — fix failures above." -ForegroundColor Red
    exit 1
}

Write-Host "L2 complete — OpenS2S inference ready" -ForegroundColor Green
Write-Host "Start services — see src/opens2s/SPIKE.md"
