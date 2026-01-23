# macOS App with Icon

## Summary

Package vimoire as a macOS application with its own dock icon, installable via homebrew or shell script. Not targeting App Store.

## Prerequisites

- **Neovide** must be installed (GUI for neovim)
- Neovim itself (neovide depends on it)
- Vimoire lua code installed to `~/.config/vimoire/` (via NVIM_APPNAME)

## The Core Challenge

macOS requires a `.app` bundle for proper dock integration. A CLI tool alone won't:
- Show an icon in the dock while running
- Be pinnable to the dock
- Have a custom icon
- Appear in Launchpad

## Options for .app Bundle Creation

### 1. Platypus (Recommended?)
[Platypus](https://sveinbjorn.org/platypus) creates native Mac apps from scripts.
- GUI and CLI interfaces
- Handles icons
- Can run as "faceless" background app or normal app
- Mature, well-maintained

### 2. appify-new
[appify-new](https://github.com/Tacolizard/appify-new) generates .app bundles from bash scripts.
- Supports custom icons
- Built-in homebrew dependency checking
- Simpler than Platypus

### 3. Manual Bundle
Create structure directly:
```
Vimoire.app/
  Contents/
    Info.plist
    MacOS/
      vimoire  (executable shell script)
    Resources/
      vimoire.icns
```

The script would be something like:
```bash
#!/bin/bash
NVIM_APPNAME=vimoire /usr/local/bin/neovide "$@"
```

### 4. Automator
Apple's built-in tool. Create Application → Run Shell Script.
- Simple but less customizable
- No CLI automation

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

Need to create:
- `vimoire.icns` — macOS icon format
- Multiple sizes (16x16 to 1024x1024)
- Can convert from PNG using `iconutil` or online tools

## Open Questions

1. Where does the lua code live? Options:
   - Bundled inside .app (self-contained but harder to update)
   - `~/.config/vimoire/` (current approach, separate from app)
   - Homebrew formula installs lua code, cask installs .app

2. How to handle updates?
   - Homebrew `brew upgrade vimoire`
   - Self-update mechanism?

3. Should we support running without neovide (terminal mode)?

## References

- [Platypus](https://sveinbjorn.org/platypus)
- [appify-new](https://github.com/Tacolizard/appify-new)
- [Create MacOS App Bundle from Script](https://relentlesscoding.com/posts/create-macos-app-bundle-from-script/)
- [Homebrew Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)
