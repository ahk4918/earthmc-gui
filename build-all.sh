#!/bin/bash

# Exit immediately if any command fails, treat unset variables as an error
set -euo pipefail

# Establish the project root path explicitly
ROOT_DIR=$(pwd)

echo "🧹 Cleaning up old build artifacts..."
rm -rf "$ROOT_DIR/dist" "$ROOT_DIR/out"

echo "🚀 Compiling cross-platform packages (DEB, RPM, and Windows EXE)..."
npm run dist:all

echo "📦 Compression phase: Packaging raw binaries into a .tar.gz archive..."
# Using a subshell (parentheses) isolates the 'cd' command so it won't break the main script's path context
(
    cd "$ROOT_DIR/dist/linux-unpacked" || exit 1
    tar -czf "$ROOT_DIR/dist/earthmc-gui-linux-x64.tar.gz" .
)

echo "📂 Creating final out/ directory at the project root..."
mkdir -p "$ROOT_DIR/out"

echo "🚚 Consolidating finished distribution packages into root out/ folder..."
# Appending '|| true' ensures that if one of the targets (like .exe) is missing, the script won't crash
find "$ROOT_DIR/dist" -maxdepth 1 -type f \( -name "*.deb" -o -name "*.rpm" -o -name "*.exe" -o -name "*.tar.gz" \) -exec mv -t "$ROOT_DIR/out/" {} + 2>/dev/null || true

echo "🗑️ Wiping out the temporary dist/ staging directory completely..."
rm -rf "$ROOT_DIR/dist"

echo -e "\n✅ Success! Staging data removed. Final production packages in out/:"
echo "----------------------------------------------------------------------------"
ls -lh "$ROOT_DIR/out"
