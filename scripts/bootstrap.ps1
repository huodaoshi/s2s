# 在 s2s 工程根目录执行： .\scripts\bootstrap.ps1
# L1 - Development environment ready
$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

. (Join-Path $PSScriptRoot "mirrors.ps1")

function Get-PipTrustedHostArgs {
    param([string[]]$Urls)
    $hosts = @()
    foreach ($u in $Urls) {
        if ($u -match '^https?://([^/:]+)') {
            $h = $Matches[1]
            if ($h -notin $hosts) { $hosts += $h }
        }
    }
    $args = @()
    foreach ($h in $hosts) {
        $args += @("--trusted-host", $h)
    }
    return $args
}

function Invoke-PipInstall {
    param(
        [string]$Python,
        [string[]]$PipArgs,
        [switch]$PytorchOnly
    )
    $index = $env:S2S_PIP_INDEX
    $pytorchIndex = "https://download.pytorch.org/whl/cu124"
    $all = @("-m", "pip") + $PipArgs
    if ($PytorchOnly) {
        $all += @("--index-url", $pytorchIndex)
        $all += Get-PipTrustedHostArgs @($pytorchIndex)
    } elseif ($index) {
        $all += @("-i", $index)
        $all += Get-PipTrustedHostArgs @($index)
    }
    & $Python @all
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

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

if ($env:S2S_USE_CN_MIRROR -ne "0") {
    Write-Host ""
    Write-Host "[L1] Using CN mirrors (set S2S_USE_CN_MIRROR=0 to disable):"
    Write-Host "  pip:     $env:S2S_PIP_INDEX"
    Write-Host "  pytorch: $env:S2S_PYTORCH_INDEX (cu124 wheels, official index)"
}

Write-Host ""
Write-Host "[L1] Installing OpenS2S dependencies (may take several minutes)..."
$req = Join-Path $Root "src\opens2s\requirements.txt"
$reqLines = Get-Content $req | Where-Object {
    $_ -notmatch '^\s*--extra-index-url' -and $_ -notmatch '^\s*$' -and $_ -notmatch '^\s*#'
}
$torchReq = Join-Path $env:TEMP "s2s-requirements-torch.txt"
$otherReq = Join-Path $env:TEMP "s2s-requirements-other.txt"
$reqLines | Where-Object { $_ -match '^(torch|torchaudio)==' } | Set-Content $torchReq -Encoding utf8
$reqLines | Where-Object { $_ -notmatch '^(torch|torchaudio)==' } | Set-Content $otherReq -Encoding utf8

Write-Host "[L1] Phase 1/2: torch + torchaudio (PyTorch cu124 index, ~2.5GB)..."
Invoke-PipInstall -Python $venvPython -PipArgs @("install", "-r", $torchReq) -PytorchOnly

Write-Host "[L1] Phase 2/2: remaining packages (PyPI mirror)..."
Invoke-PipInstall -Python $venvPython -PipArgs @("install", "-r", $otherReq)

Write-Host ""
Write-Host "[L1] Verifying torch import..."
& $venvPython -c "import torch; print('torch', torch.__version__, 'cuda built:', torch.version.cuda, 'cuda ok:', torch.cuda.is_available())"
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: torch import failed. On Windows, torch 2.4.0 may need libomp140; use 2.4.1+cu124 (see requirements.txt)."
    exit 1
}

Write-Host ""
Write-Host "========================================"
Write-Host " L1 complete - Development environment ready"
Write-Host "========================================"
Write-Host ""
Write-Host "Next:"
Write-Host "  . .\scripts\env.ps1"
Write-Host ""
Write-Host "For OpenS2S L2 (inference ready), see docs/INSTALL.md:"
Write-Host "  .\scripts\download-opens2s-models.ps1"
Write-Host "  .\scripts\check-l2-opens2s.ps1"
