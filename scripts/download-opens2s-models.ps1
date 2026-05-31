# 在 s2s 工程根目录执行： .\scripts\download-opens2s-models.ps1
# OpenS2S L2 — 下载 Model artifact directories
$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

. (Join-Path $PSScriptRoot "mirrors.ps1")
. (Join-Path $PSScriptRoot "env.ps1")

$venvPython = Join-Path $Root "env\.venv\Scripts\python.exe"
if (-not (Test-Path $venvPython)) {
    Write-Host "ERROR: venv not found. Run .\scripts\bootstrap.ps1 first."
    exit 1
}

function Test-HfReachable {
    param([string]$Url)
    try {
        Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 10 -UseBasicParsing | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Resolve-HfEndpoint {
    if ($env:HF_ENDPOINT) {
        return $env:HF_ENDPOINT.TrimEnd("/")
    }
    if ($env:S2S_HF_USE_MIRROR -eq "1") {
        return "https://hf-mirror.com"
    }
    if ($env:S2S_USE_CN_MIRROR -ne "0") {
        if (Test-HfReachable "https://hf-mirror.com") {
            return "https://hf-mirror.com"
        }
    }
    if (Test-HfReachable "https://huggingface.co") {
        return "https://huggingface.co"
    }
    if (Test-HfReachable "https://hf-mirror.com") {
        return "https://hf-mirror.com"
    }
    Write-Host "ERROR: cannot reach huggingface.co or hf-mirror.com"
    exit 1
}

$hfEndpoint = Resolve-HfEndpoint
$env:HF_ENDPOINT = $hfEndpoint
Write-Host "[s2s] HF endpoint: $hfEndpoint"

$downloads = @(
    @{ Dir = "casia-opens2s";            Repo = "CASIA-LM/OpenS2S" },
    @{ Dir = "thudm-glm4-voice-decoder"; Repo = "THUDM/glm-4-voice-decoder" }
)

function Invoke-HfDownload {
    param([string]$Repo, [string]$LocalDir, [string]$Endpoint)
    New-Item -ItemType Directory -Path $LocalDir -Force | Out-Null
    Write-Host ""
    Write-Host "Downloading $Repo -> $LocalDir"
    $py = @"
import os
from huggingface_hub import HfApi

endpoint = r'$Endpoint'
os.environ['HF_ENDPOINT'] = endpoint
api = HfApi(endpoint=endpoint)
api.snapshot_download(
    repo_id=r'$Repo',
    local_dir=r'$LocalDir',
    max_workers=2,
)
print('DOWNLOAD_OK')
"@
    $env:PYTHONUTF8 = "1"
    & $venvPython -c $py | Write-Host
    if ($LASTEXITCODE -ne 0) {
        return $LASTEXITCODE
    }
    return 0
}

foreach ($item in $downloads) {
    $localDir = Join-Path $Root ("models\" + $item.Dir)
    $code = Invoke-HfDownload -Repo $item.Repo -LocalDir $localDir -Endpoint $hfEndpoint
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
