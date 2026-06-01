# 在 s2s 工程根目录执行： .\scripts\check-l2-minimind.ps1
# MiniMind L2 — reproduction ready 文件门禁（C1，不跑 eval_llm）
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

Write-Host "MiniMind L2 checks (file gates)"
Write-Host "=============================="
Write-Host ""

$venvPython = Join-Path $Root "env\.venv-minimind\Scripts\python.exe"
if (-not (Test-Path $venvPython)) {
    Fail-Check "env/.venv-minimind not found - run .\scripts\bootstrap-minimind.ps1"
} else {
    Pass-Check "M1 venv present (run .\scripts\check-m1-minimind.ps1 for full M1)"
}

$datasetFiles = @(
    "src\minimind\dataset\pretrain_t2t_mini.jsonl",
    "src\minimind\dataset\sft_t2t_mini.jsonl"
)
foreach ($rel in $datasetFiles) {
    $p = Join-Path $Root $rel
    if ((Test-Path $p) -and ((Get-Item $p).Length -gt 0)) {
        Pass-Check "$rel exists and is non-empty"
    } else {
        Fail-Check "$rel missing or empty"
        Write-Host "      Run: .\scripts\download-minimind-dataset.ps1"
    }
}

$checkpoints = @(
    "src\minimind\out\pretrain_768.pth",
    "src\minimind\out\full_sft_768.pth"
)
foreach ($rel in $checkpoints) {
    $p = Join-Path $Root $rel
    if ((Test-Path $p) -and ((Get-Item $p).Length -gt 0)) {
        Pass-Check "$rel exists and is non-empty"
    } else {
        Fail-Check "$rel missing or empty"
        Write-Host "      Train in src\minimind\trainer\ - see src\minimind\SPIKE.md"
    }
}

Write-Host ""
if ($failed) {
    Write-Host "L2 NOT ready - fix failures above." -ForegroundColor Red
    Write-Host "After checkpoints exist, manually run eval_llm.py for dialogue quality."
    exit 1
}

Write-Host "L2 file gates passed - MiniMind reproduction ready (artifacts)" -ForegroundColor Green
Write-Host "Manually verify: python eval_llm.py --load_from model --weight full_sft (from src/minimind)"
