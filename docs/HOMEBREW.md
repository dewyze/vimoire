# Homebrew Cask for Vimoire

## Goal

Create a homebrew cask that installs Vimoire as a macOS application, including:
- The `.app` bundle to `/Applications/`
- The lua config to `~/.config/vimoire/`

## What Gets Installed

| Source | Destination |
|--------|-------------|
| `platform/macos/Vimoire.app/` | `/Applications/Vimoire.app` |
| `app/` (lua code, templates, colors) | `~/.config/vimoire/` |

## Dependencies

- `neovide` (cask) — the GUI that runs neovim
- `neovim` (formula) — neovide depends on this already

## Cask Structure

Homebrew casks install from a release artifact (typically a `.zip` or `.dmg`). We need to:

1. **Create a release archive** containing both the `.app` bundle and the `app/` lua code
2. **Write the cask formula** that:
   - Downloads the release archive
   - Installs `Vimoire.app` to `/Applications/`
   - Copies lua code to `~/.config/vimoire/` (via postflight)
   - Declares dependencies on neovide

### Release Archive Structure

```
vimoire-0.1.0.zip
├── Vimoire.app/
│   └── Contents/...
└── config/
    ├── init.lua
    ├── lua/
    ├── colors/
    ├── syntax/
    ├── templates/
    └── lazy-lock.json
```

### Cask Formula (`vimoire.rb`)

```ruby
cask "vimoire" do
  version "0.1.0"
  sha256 "..." # computed from release zip

  url "https://github.com/dewyze/vimoire/releases/download/v#{version}/vimoire-#{version}.zip"
  name "Vimoire"
  desc "Focused writing environment for novelists"
  homepage "https://github.com/dewyze/vimoire"

  depends_on cask: "neovide"

  app "Vimoire.app"

  postflight do
    config_dir = "#{Dir.home}/.config/vimoire"
    unless File.exist?(config_dir)
      FileUtils.mkdir_p(config_dir)
      FileUtils.cp_r(staged_path.join("config/."), config_dir)
    end
  end

  uninstall_postflight do
    # Optionally clean up config, or leave it for user data preservation
  end

  zap trash: "~/.config/vimoire"
end
```

## Tasks

### 1. Create release build script (`bin/build-release`)
- Assembles the zip archive from `platform/macos/Vimoire.app/` and `app/`
- Outputs to `dist/vimoire-VERSION.zip`
- Computes and prints sha256

### 2. Create the cask formula
- File: `homebrew/vimoire.rb` (or separate tap repo)
- References GitHub releases URL

### 3. Update docs
- Add installation instructions to README
- Update `docs/mvp/macos-app.md` with cask details

## Decisions

- **GitHub repo:** `dewyze/vimoire`
- **Config install:** Skip if `~/.config/vimoire/` exists (preserve user customizations)

## Open Questions

1. **Separate tap or homebrew-core?** — Homebrew-core has stricter requirements. A tap (e.g., `dewyze/homebrew-vimoire`) is easier to start.
2. **Neovide version requirement** — The `--icon` flag needs nightly or future stable. Should the cask note this, or wait until stable includes it?

## Verification

1. Run `bin/build-release` and verify zip contents
2. Install locally: `brew install --cask ./homebrew/vimoire.rb`
3. Launch `/Applications/Vimoire.app`
4. Verify `~/.config/vimoire/` has all files
5. Open a test manuscript
