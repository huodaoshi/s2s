# 在 s2s 工程根目录执行： .\scripts\bootstrap-minimind.ps1
# M1 — MiniMind environment ready
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
    Write-Host "Install manually, then re-run bootstrap-minimind:"
    Write-Host "  choco install python310 -y"
    Write-Host "  Or: https://www.python.org/downloads/release/python-31011/"
    exit 1
}

Write-Host "Using Python: $py310"
& $py310 --version

$venv = Join-Path $Root "env\.venv-minimind"
$venvPython = Join-Path $venv "Scripts\python.exe"
if (-not (Test-Path $venvPython)) {
    & $py310 -m venv $venv
    Write-Host "created venv: $venv"
} else {
    Write-Host "venv exists: $venv"
}

$datasetDir = Join-Path $Root "src\minimind\dataset"
if (-not (Test-Path $datasetDir)) {
    New-Item -ItemType Directory -Path $datasetDir -Force | Out-Null
}

if ($env:S2S_USE_CN_MIRROR -ne "0") {
    Write-Host ""
    Write-Host "[M1] Using CN mirrors (set S2S_USE_CN_MIRROR=0 to disable):"
    Write-Host "  pip:     $env:S2S_PIP_INDEX"
    Write-Host "  pytorch: $env:S2S_PYTORCH_INDEX (cu124 wheels, official index)"
}

Write-Host ""
Write-Host "[M1] Installing PyTorch cu124 (aligned with OpenS2S L1)..."
$torchReq = Join-Path $env:TEMP "s2s-minimind-requirements-torch.txt"
@(
    "torch==2.4.0+cu124"
    "torchaudio==2.4.0+cu124"
) | Set-Content $torchReq -Encoding utf8
Invoke-PipInstall -Python $venvPython -PipArgs @("install", "-r", $torchReq) -PytorchOnly

Write-Host ""
Write-Host "[M1] Installing MiniMind dependencies (may take several minutes)..."
$req = Join-Path $Root "src\minimind\requirements.txt"
$reqLines = Get-Content $req | Where-Object {
    $_ -notmatch '^\s*--extra-index-url' -and $_ -notmatch '^\s*$' -and $_ -notmatch '^\s*#'
}
$otherReq = Join-Path $env:TEMP "s2s-minimind-requirements-other.txt"
$reqLines | Where-Object { $_ -notmatch '^(torch|torchaudio)==' } | Set-Content $otherReq -Encoding utf8
Invoke-PipInstall -Python $venvPython -PipArgs @("install", "-r", $otherReq)

Write-Host ""
Write-Host "[M1] Verifying torch + transformers..."
& $venvPython -c "import torch; import transformers; print('torch', torch.__version__, 'cuda ok:', torch.cuda.is_available()); print('transformers', transformers.__version__)"
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: import failed."
    exit 1
}

Write-Host ""
Write-Host "========================================"
Write-Host " M1 complete - MiniMind environment ready"
Write-Host "========================================"
Write-Host ""
Write-Host "Next:"
Write-Host "  . .\scripts\env-minimind.ps1"
Write-Host "  .\scripts\check-m1-minimind.ps1"
Write-Host ""
Write-Host "For MiniMind L2, see docs/INSTALL.md (MiniMind section):"
