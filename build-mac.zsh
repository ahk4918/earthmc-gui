#!/bin/zsh

# Exit immediately if any command fails
set -e

# Establish the project root path explicitly
ROOT_DIR=$(pwd)

print -P "%F{cyan}🧹 Cleaning up old build artifacts...%f"
rm -rf "$ROOT_DIR/dist" "$ROOT_DIR/out"

# Verify dependencies exist, install safely if missing
if [ ! -d "node_modules" ]; then
  print -P "%F{yellow}📦 node_modules not found. Running clean npm installation...%f"
  npm ci
fi

print -P "%F{cyan}🚀 Compiling macOS packages (.dmg and .zip)...%f"
# Runs electron-builder via your package.json script
npm run dist:mac

print -P "%F{cyan}📂 Creating final out/ directory at the project root...%f"
mkdir -p "$ROOT_DIR/out"

print -P "%F{cyan}🚚 Moving finished Mac packages into root out/ folder...%f"
# Moves dmg and zip files while ignoring errors if any are missing
mv "$ROOT_DIR/dist"/*.dmg "$ROOT_DIR/out/" 2>/dev/null || true
mv "$ROOT_DIR/dist"/*.zip "$ROOT_DIR/out/" 2>/dev/null || true

print -P "%F{cyan}🗑️ Wiping out the temporary dist/ staging directory...%f"
rm -rf "$ROOT_DIR/dist"

print -P "\n%F{green}✅ Success! Production packages ready in out/:%f"
print -P "%F{green}------------------------------------------------------------%f"
ls -lh "$ROOT_DIR/out"
