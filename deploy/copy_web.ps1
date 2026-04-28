# Copies build/web -> deploy/web (e.g. for Render).
# If index.html is missing, runs flutter build web automatically.
param(
    [switch] $SkipBuild  # Fail without building (old behavior).
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src = Join-Path $root "build\web"
$dest = Join-Path $root "deploy\web"
$index = Join-Path $src "index.html"

if (-not (Test-Path $index)) {
    if ($SkipBuild) {
        throw "Not found: $index - Run from repo root: flutter build web -- Path: $root"
    }
    Write-Host "[copy_web] build/web missing -> running flutter pub get && flutter build web ..." -ForegroundColor Cyan
    Push-Location $root
    try {
        & flutter pub get
        if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed (exit $LASTEXITCODE)" }
        & flutter build web
        if ($LASTEXITCODE -ne 0) { throw "flutter build web failed (exit $LASTEXITCODE)" }
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-Path $index)) {
    throw "Still missing after build: $index"
}

New-Item -ItemType Directory -Force -Path $dest | Out-Null
Get-ChildItem -Path $dest -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $src "*") -Destination $dest -Recurse -Force
Write-Host "[copy_web] OK -> $dest (commit and push if deploying to Render)." -ForegroundColor Green
