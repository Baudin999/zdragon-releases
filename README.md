# ZDragon Releases

This repository contains release binaries for ZDragon.

## Download

Download the latest release from the [Releases page](https://github.com/Baudin999/zdragon-releases/releases).

## Installation

### macOS (Recommended)

Run this command in Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/Baudin999/zdragon-releases/master/install.sh | bash
```

This will:
- Download the latest version
- Install to /Applications
- Remove the quarantine attribute (fixes "app is damaged" error)

### macOS (Manual)

1. Download the `.zip` file
2. Extract it
3. Move `zdragon.app` to `/Applications`
4. Open Terminal and run:
   ```bash
   xattr -cr /Applications/zdragon.app
   ```
5. Open ZDragon from Applications

### Windows

1. Download the `.zip` file
2. Extract it
3. Run `zdragon.exe`

### Linux

1. Download the `.tar.gz` file
2. Extract it: `tar -xzf zdragon_linux_amd64.tar.gz`
3. Run `./zdragon`

Note: Linux users need to install Graphviz separately (`apt install graphviz` or equivalent).

