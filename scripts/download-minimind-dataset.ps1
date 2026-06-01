# 在 s2s 工程根目录执行： .\scripts\download-minimind-dataset.ps1
# 下载 MiniMind mini 训练 jsonl 到 src/minimind/dataset/
$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

. (Join-Path $PSScriptRoot "mirrors.ps1")

$venvPython = Join-Path $Root "env\.venv-minimind\Scripts\python.exe"
if (-not (Test-Path $venvPython)) {
    Write-Host "ERROR: env/.venv-minimind not found. Run .\scripts\bootstrap-minimind.ps1 first."
    exit 1
}

$datasetDir = Join-Path $Root "src\minimind\dataset"
New-Item -ItemType Directory -Path $datasetDir -Force | Out-Null

$files = @("pretrain_t2t_mini.jsonl", "sft_t2t_mini.jsonl")
$allPresent = $true
foreach ($f in $files) {
    $p = Join-Path $datasetDir $f
    if ((Test-Path $p) -and ((Get-Item $p).Length -gt 0)) {
        Write-Host "OK:   $f already present ($([math]::Round((Get-Item $p).Length / 1MB, 2)) MB)"
    } else {
        $allPresent = $false
    }
}
if ($allPresent) {
    Write-Host ""
    Write-Host "MiniMind mini dataset already ready: $datasetDir"
    exit 0
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
    Write-Host "ERROR: cannot reach huggingface.co or hf-mirror.com"
    exit 1
}

$hfEndpoint = Resolve-HfEndpoint
$env:HF_ENDPOINT = $hfEndpoint

Write-Host "[minimind] Dataset target: $datasetDir"
Write-Host "[minimind] HF fallback endpoint: $hfEndpoint"
Write-Host ""

$py = @"
import os
import shutil
import sys
from pathlib import Path

FILES = ["pretrain_t2t_mini.jsonl", "sft_t2t_mini.jsonl"]
DEST = Path(r"$datasetDir")
DEST.mkdir(parents=True, exist_ok=True)
HF_ENDPOINT = r"$hfEndpoint"
errors = []


def ensure_file(name: str, src: Path) -> None:
    target = DEST / name
    if target.exists() and target.stat().st_size > 0:
        return
    if not src.is_file() or src.stat().st_size == 0:
        raise FileNotFoundError(f"missing or empty source for {name}: {src}")
    shutil.copy2(src, target)
    print(f"COPIED|{name}|{target.stat().st_size}")


def download_via_modelscope() -> None:
    from modelscope.hub.snapshot_download import snapshot_download

    cache_dir = snapshot_download("gongjy/minimind_dataset", repo_type="dataset")
    root = Path(cache_dir)
    for name in FILES:
        candidates = list(root.rglob(name))
        if not candidates:
            raise FileNotFoundError(f"{name} not found under ModelScope cache {root}")
        ensure_file(name, candidates[0])
    print("MS_OK")


def download_via_hf() -> None:
    os.environ["HF_ENDPOINT"] = HF_ENDPOINT
    from huggingface_hub import hf_hub_download

    for name in FILES:
        path = hf_hub_download(
            repo_id="jingyaogong/minimind_dataset",
            filename=name,
            repo_type="dataset",
            local_dir=str(DEST),
        )
        p = Path(path)
        if not p.is_file():
            p = DEST / name
        ensure_file(name, p)
    print("HF_OK")


try:
    download_via_modelscope()
except Exception as exc:
    print(f"MS_FAIL|{exc}", file=sys.stderr)
    try:
        download_via_hf()
    except Exception as exc2:
        print(f"HF_FAIL|{exc2}", file=sys.stderr)
        sys.exit(1)

for name in FILES:
    p = DEST / name
    if not p.is_file() or p.stat().st_size == 0:
        print(f"MISSING|{name}", file=sys.stderr)
        sys.exit(1)
    print(f"READY|{name}|{p.stat().st_size}")
print("DOWNLOAD_OK")
"@

$env:PYTHONUTF8 = "1"
& $venvPython -c $py | Write-Host
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: dataset download failed."
    Write-Host "ModelScope dataset: gongjy/minimind_dataset"
    Write-Host "HF dataset: jingyaogong/minimind_dataset"
    Write-Host "If HF is gated, set HF_TOKEN or run: huggingface-cli login"
    exit 1
}

Write-Host ""
Write-Host "MiniMind mini dataset ready."
Write-Host "Next: train per src/minimind/SPIKE.md, then .\scripts\check-l2-minimind.ps1"
