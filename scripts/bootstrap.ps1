# 在 s2s 工程根目录执行： .\scripts\bootstrap.ps1
# L1 — Development environment ready
$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

$dirs = @(
    "env",
    "models",
    "cache\huggingface\hub",
    "logs",
    "src\opens2s",
    "src\volc-realtime",
    "src\stepfun-realtime",
    "docs\references"
)
foreach ($d in $dirs) {
    $p = Join-Path $Root $d
    if (-not (Test-Path $p)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
        Write-Host "created: $p"
    }
}

function Find-Python310 {
    $candidates = @(
        "python3.10",
        "C:\ProgramData\chocolatey\bin\python3.10.exe",
        "E:\Python310\python.exe",
        "C:\Python310\python.exe"
    )
    foreach ($c in $candidates) {
        if (Get-Command $c -ErrorAction SilentlyContinue) {
            return (Get-Command $c).Source
        }
        if (Test-Path $c) { return $c }
    }
    return $null
}

$py310 = Find-Python310
if (-not $py310) {
    Write-Host ""
    Write-Host "ERROR: Python 3.10 not found."
    Write-Host "Install manually, then re-run bootstrap:"
    Write-Host "  choco install python310 -y"
    Write-Host "  Or: https://www.python.org/downloads/release/python-31011/"
    Write-Host ""
    Write-Host "Directory scaffold is ready; re-run after installing Python 3.10."
    exit 1
}

Write-Host "Using Python: $py310"
& $py310 --version

$venv = Join-Path $Root "env\.venv"
$venvPython = Join-Path $venv "Scripts\python.exe"
if (-not (Test-Path $venvPython)) {
    & $py310 -m venv $venv
    Write-Host "created venv: $venv"
} else {
    Write-Host "venv exists: $venv"
}

Write-Host ""
Write-Host "[L1] Installing OpenS2S dependencies (may take several minutes)..."
$req = Join-Path $Root "src\opens2s\requirements.txt"
& $venvPython -m pip install --upgrade pip
& $venvPython -m pip install -r $req

Write-Host ""
Write-Host "[L1] Verifying torch import..."
& $venvPython -c "import torch; print('torch', torch.__version__, 'cuda built:', torch.version.cuda)"

Write-Host ""
Write-Host "========================================"
Write-Host " L1 complete — Development environment ready"
Write-Host "========================================"
Write-Host ""
Write-Host "Next:"
Write-Host "  . .\scripts\env.ps1"
Write-Host ""
Write-Host "For OpenS2S L2 (inference ready), see docs/INSTALL.md:"
Write-Host "  .\scripts\download-opens2s-models.ps1"
Write-Host "  .\scripts\check-l2-opens2s.ps1"
