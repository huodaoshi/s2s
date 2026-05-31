# 在 s2s 工程根目录执行： .\scripts\download-opens2s-models.ps1
# OpenS2S L2 — 下载 Model artifact directories
$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

. (Join-Path $PSScriptRoot "env.ps1")

$venvPython = Join-Path $Root "env\.venv\Scripts\python.exe"
if (-not (Test-Path $venvPython)) {
    Write-Host "ERROR: venv not found. Run .\scripts\bootstrap.ps1 first."
    exit 1
}

$downloads = @(
    @{ Dir = "casia-opens2s";            Repo = "CASIA-LM/OpenS2S" },
    @{ Dir = "thudm-glm4-voice-decoder"; Repo = "THUDM/glm-4-voice-decoder" }
)

function Invoke-HfDownload {
    param([string]$Repo, [string]$LocalDir)
    New-Item -ItemType Directory -Path $LocalDir -Force | Out-Null
    Write-Host ""
    Write-Host "Downloading $Repo -> $LocalDir"
    & $venvPython -m huggingface_hub.cli download $Repo --local-dir $LocalDir
    return $LASTEXITCODE
}

foreach ($item in $downloads) {
    $localDir = Join-Path $Root ("models\" + $item.Dir)
    $code = Invoke-HfDownload -Repo $item.Repo -LocalDir $localDir
    if ($code -ne 0) {
        Write-Host ""
        Write-Host "ERROR: download failed for $($item.Repo) (exit $code)"
        Write-Host "If the model is gated or requires login:"
        Write-Host "  1. Set HF_TOKEN or HUGGINGFACE_HUB_TOKEN in your environment, or"
        Write-Host "  2. Run: huggingface-cli login"
        Write-Host "Then re-run: .\scripts\download-opens2s-models.ps1"
        exit $code
    }
}

Write-Host ""
Write-Host "Model downloads complete."
Write-Host "Next: .\scripts\check-l2-opens2s.ps1"
