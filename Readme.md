# EarthMC GUI

A desktop client for browsing and managing EarthMC server data.

## Features
- Browse nations, towns, and online players
- Player tracker with join/leave alerts
- Shop manager (requires API key)
- Auto-updates via GitHub Releases

## Install
Download the latest release for your platform from [Releases](https://github.com/YOUR_USERNAME/earthmc-gui/releases).

| Platform | File |
|----------|------|
| Linux (Debian/Ubuntu) | `.deb` |
| Linux (Fedora/RHEL) | `.rpm` |
| Linux (other) | `.tar.gz` |
| Windows | `.exe` |

## Build from source
```bash
npm install
npm start          # run in dev
npm run dist:linux # build for linux
npm run dist:all   # build for linux + windows
```

## License
ISC