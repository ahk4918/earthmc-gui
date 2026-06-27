# Stop execution immediately if any native cmdlet fails
$ErrorActionPreference = "Stop"

# Establish the project root path explicitly
$ROOT_DIR = Get-Item .

# Dynamically parse package metadata to avoid hardcoded version errors
$PackageJson = Get-Content -Raw -Path "$ROOT_DIR\package.json" | ConvertFrom-Json
$ProductName = $PackageJson.build.productName -replace '\s+', '-' # "EarthMC-GUI"
$Version     = $PackageJson.version # "1.0.0"

Write-Host "🧹 Cleaning up old build artifacts..."
If (Test-Path "$ROOT_DIR\dist") { Remove-Item -Recurse -Force "$ROOT_DIR\dist" }
If (Test-Path "$ROOT_DIR\out") { Remove-Item -Recurse -Force "$ROOT_DIR\out" }

Write-Host "🚀 Compiling cross-platform packages (DEB, RPM, and Windows EXE)..."
npm run dist:linux

# CRITICAL FIX: Explicitly intercept external process failures (Equivalent to set -e for npm)
if ($LASTEXITCODE -ne 0) {
    Write-Error "npm compilation failed with exit code $LASTEXITCODE."
    Exit $LASTEXITCODE
}

Write-Host "📦 Compression phase: Packaging raw binaries into a .tar.gz archive..."
# Uses native tar.exe built into Windows 10 and 11
Push-Location "$ROOT_DIR\dist\linux-unpacked"
tar.exe -czf "$ROOT_DIR\dist\earthmc-gui-linux-x64.tar.gz" .
Pop-Location

Write-Host "📂 Creating final out/ directory at the project root..."
New-Item -ItemType Directory -Force -Path "$ROOT_DIR\out" | Out-Null

Write-Host "🚚 Consolidating finished distribution packages into root out/ folder..."
# Find and safely move all installers and archives from dist into the root out folder
Get-ChildItem -Path "$ROOT_DIR\dist" -File | 
    Where-Object { $_.Extension -match '^\.(deb|rpm|gz)$' } | 
    Move-Item -Destination "$ROOT_DIR\out\"

Write-Host "🗑️ Wiping out the temporary dist/ staging directory completely..."
If (Test-Path "$ROOT_DIR\dist") { Remove-Item -Recurse -Force "$ROOT_DIR\dist" }

Write-Host "`n✅ Success! Staging data removed. Final production packages in out/:"
Write-Host "----------------------------------------------------------------------------"
Get-ChildItem -Path "$ROOT_DIR\out" | Select-Object Name, @{Name="Size(MB)";Expression={[math]::round($_.Length / 1MB, 2)}}
