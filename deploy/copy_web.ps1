# Copies build/web -> deploy/web (e.g. Render static).
# Ensures sqflite web binaries exist, then builds if needed, then copies.
param(
    [switch] $SkipBuild
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src = Join-Path $root "build\web"
$dest = Join-Path $root "deploy\web"
$index = Join-Path $src "index.html"
$wasm = Join-Path $src "sqlite3.wasm"
$swJs = Join-Path $src "sqflite_sw.js"

Push-Location $root
try {
    & flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed (exit $LASTEXITCODE)" }
    & dart run sqflite_common_ffi_web:setup
    if ($LASTEXITCODE -ne 0) { throw "sqflite_common_ffi_web:setup failed (exit $LASTEXITCODE)" }
}
finally {
    Pop-Location
}

$needBuild = (-not (Test-Path $index)) -or (-not (Test-Path $wasm)) -or (-not (Test-Path $swJs))
if ($needBuild) {
    if ($SkipBuild) {
        throw "Missing build/web output. Need: index.html, sqlite3.wasm, sqflite_sw.js. Run without -SkipBuild or: flutter build web from: $root"
    }
    Write-Host "[copy_web] building flutter web (sqflite wasm required for app DB)..." -ForegroundColor Cyan
    Push-Location $root
    try {
        & flutter build web
        if ($LASTEXITCODE -ne 0) { throw "flutter build web failed (exit $LASTEXITCODE)" }
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-Path $index)) { throw "Still missing: $index" }
if (-not (Test-Path $wasm)) {
    throw "Still missing SQLite wasm (required on web): $wasm . Run: dart run sqflite_common_ffi_web:setup then flutter build web"
}
if (-not (Test-Path $swJs)) {
    throw "Still missing: $swJs"
}

New-Item -ItemType Directory -Force -Path $dest | Out-Null
Get-ChildItem -Path $dest -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $src "*") -Destination $dest -Recurse -Force
Write-Host "[copy_web] OK -> $dest (push to deploy)." -ForegroundColor Green
