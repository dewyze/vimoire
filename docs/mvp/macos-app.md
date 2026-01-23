# macOS App with Icon

## Summary

Package vimoire as a macOS application with its own dock icon, installable via homebrew or shell script. Not targeting App Store.

## Prerequisites

- **Neovide** with `--icon` support (available in nightly builds, expected in next stable release after 0.15.2)
- Neovim itself (neovide depends on it)
- Vimoire lua code installed to `~/.config/vimoire/` (via NVIM_APPNAME)

## The Core Challenge

macOS requires a `.app` bundle for proper dock integration. A CLI tool alone won't:
- Show an icon in the dock while running
- Be pinnable to the dock
- Have a custom icon
- Appear in Launchpad

Additionally, when a launcher script spawns neovide, neovide becomes the GUI process—so its icon and app name show in the dock/menu bar, not the launcher's.

## Solution: Manual Bundle + `--icon` Flag

**Tested and working.** Neovide's `--icon` flag (merged in [PR #3272](https://github.com/neovide/neovide/pull/3272), October 2025) allows custom dock icons. Combined with a manual `.app` bundle, we get full branding:

| What | How | Result |
|------|-----|--------|
| App name | `CFBundleName` in `Info.plist` | "Vimoire" |
| Menu bar (top-level) | `Info.plist` | "Vimoire" |
| Dock icon | `--icon` flag | Custom icon |
| Window title | Already handled in `setup.lua` | "Vimoire — {book title}" |
| Menu items inside | Hardcoded in neovide | "neovide" (acceptable) |

### Bundle Structure

```
Vimoire.app/
  Contents/
    Info.plist
    MacOS/
      vimoire  (executable shell script)
    Resources/
      vimoire.icns
```

### Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Vimoire</string>
    <key>CFBundleDisplayName</key>
    <string>Vimoire</string>
    <key>CFBundleIdentifier</key>
    <string>dev.vimoire.app</string>
    <key>CFBundleVersion</key>
    <string>0.1.0</string>
    <key>CFBundleExecutable</key>
    <string>vimoire</string>
    <key>CFBundleIconFile</key>
    <string>vimoire</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
</dict>
</plist>
```

### Launcher Script

```bash
#!/bin/bash
NVIM_APPNAME=vimoire /opt/homebrew/bin/neovide --icon /path/to/vimoire.icns "$@"
```

## Rejected Approaches

- **Platypus / appify-new** — Overkill for a 2-line launcher script
- **Automator** — Can't automate creation, icons are a pain
- **Bundling neovide binary inside .app** — Unnecessary now that `--icon` exists

## Installation via Homebrew

Homebrew casks support:
- `depends_on cask: "neovide"` — ensure neovide is installed
- `depends_on formula: "neovim"` — ensure neovim is installed
- `preflight` / `postflight` hooks — run setup scripts
- `app` stanza — install the .app bundle to /Applications

### Proposed Cask Structure
```ruby
cask "vimoire" do
  version "0.1.0"
  sha256 "..."

  url "https://github.com/user/vimoire/releases/download/v#{version}/Vimoire.app.zip"
  name "Vimoire"
  desc "Focused writing environment for novelists"
  homepage "https://github.com/user/vimoire"

  depends_on cask: "neovide"
  depends_on formula: "neovim"

  app "Vimoire.app"

  postflight do
    # Clone/copy lua code to ~/.config/vimoire/ if needed
  end
end
```

### Alternative: Shell Script Install

```bash
curl -fsSL https://vimoire.dev/install.sh | bash
```

Script would:
1. Check for / install homebrew
2. `brew install neovim neovide`
3. Download and install Vimoire.app
4. Set up ~/.config/vimoire/

## Icon

Source icon lives at `assets/icon.png`. To regenerate the `.icns` after updating the source:

```bash
bin/build-icon
```

This creates `platform/macos/Vimoire.app/Contents/Resources/vimoire.icns` with all required sizes (16x16 to 1024x1024).

## Open Questions

1. Where does the lua code live? Options:
   - Bundled inside .app (self-contained but harder to update)
   - `~/.config/vimoire/` (current approach, separate from app)
   - Homebrew formula installs lua code, cask installs .app

2. How to handle updates?
   - Homebrew `brew upgrade vimoire`
   - Self-update mechanism?

3. Should we support running without neovide (terminal mode)?

4. Wait for neovide stable release with `--icon`, or require nightly for now?

## References

- [Neovide --icon PR #3272](https://github.com/neovide/neovide/pull/3272)
- [Neovide dock icon issue #2929](https://github.com/neovide/neovide/issues/2929)
- [Create MacOS App Bundle from Script](https://relentlesscoding.com/posts/create-macos-app-bundle-from-script/)
- [Homebrew Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)
