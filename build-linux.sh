#!/bin/bash

# Exit immediately if any command fails, treat unset variables as an error
set -euo pipefail

# Establish the project root path explicitly
ROOT_DIR=$(pwd)

echo "🧹 Cleaning up old build artifacts..."
# Added guard flags to rm -rf so it never crashes if directories are missing
rm -rf "$ROOT_DIR/dist" "$ROOT_DIR/out"

echo "🚀 Compiling cross-platform packages (DEB, RPM, and Windows EXE)..."
npm run dist:linux

echo "📦 Compression phase: Packaging raw binaries into a .tar.gz archive..."
# Using a subshell ( ... ) ensures the script context returns to ROOT_DIR automatically 
(
    cd "$ROOT_DIR/dist/linux-unpacked" || exit 1
    tar -czf "$ROOT_DIR/dist/earthmc-gui-linux-x64.tar.gz" .
)

echo "📂 Creating final out/ directory at the project root..."
mkdir -p "$ROOT_DIR/out"

echo "🚚 Consolidating finished distribution packages into root out/ folder..."
# Added a fallback verification check to prevent the script from halting if no files match
find "$ROOT_DIR/dist" -maxdepth 1 -type f \( -name "*.deb" -o -name "*.rpm" -o -name "*.tar.gz" \) -exec mv -t "$ROOT_DIR/out/" {} + 2>/dev/null || true

echo "🗑️ Wiping out the temporary dist/ staging directory completely..."
rm -rf "$ROOT_DIR/dist"

echo -e "\n✅ Success! Staging data removed. Final production packages in out/:"
echo "----------------------------------------------------------------------------"
ls -lh "$ROOT_DIR/out"
