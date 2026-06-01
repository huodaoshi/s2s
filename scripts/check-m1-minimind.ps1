# 在 s2s 工程根目录执行： .\scripts\check-m1-minimind.ps1
# M1 — MiniMind environment ready 验收
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

Write-Host "MiniMind M1 checks"
Write-Host "=================="
Write-Host ""

$venvPython = Join-Path $Root "env\.venv-minimind\Scripts\python.exe"
if (-not (Test-Path $venvPython)) {
    Fail-Check "env/.venv-minimind not found"
    Write-Host "      Run: .\scripts\bootstrap-minimind.ps1"
} else {
    Pass-Check "env/.venv-minimind exists"
    $result = & $venvPython -c @"
import sys
import torch
import transformers
if not torch.cuda.is_available():
    print('CUDA_NOT_AVAILABLE')
    sys.exit(1)
p = torch.cuda.get_device_properties(0)
print('CUDA_OK|' + torch.cuda.get_device_name(0) + '|' + str(round(p.total_memory / (1024**3), 1)))
print('PKGS_OK|torch=' + torch.__version__ + '|transformers=' + transformers.__version__)
"@ 2>&1
    if ($LASTEXITCODE -ne 0 -or ($result -match "CUDA_NOT_AVAILABLE")) {
        Fail-Check "torch.cuda.is_available() is False"
        Write-Host "      MiniMind L2 training requires CUDA (see docs/INSTALL.md)."
    } else {
        $parts = ($result | Where-Object { $_ -match "^CUDA_OK" }) -split "\|"
        Pass-Check ("CUDA available - " + $parts[1] + ", " + $parts[2] + " GB VRAM")
        $pkg = ($result | Where-Object { $_ -match "^PKGS_OK" }) -split "\|"
        Pass-Check ($pkg[1] + ", " + $pkg[2])
    }
}

Write-Host ""
if ($failed) {
    Write-Host "M1 NOT ready - fix failures above." -ForegroundColor Red
    exit 1
}

Write-Host "M1 complete - MiniMind environment ready" -ForegroundColor Green
Write-Host "Next: .\scripts\download-minimind-dataset.ps1"
