# macOS App Bundle

Vimoire has two launch paths, both driving the same `NVIM_APPNAME=vimoire` config:

| Entry point | Command | Editor | Notes |
|-------------|---------|--------|-------|
| GUI | `bin/vimoire` | Neovide | Dock icon (`--icon`), single-instance via `/tmp/vimoire.sock` |
| Terminal / tmux | `bin/term-vimoire` | terminal nvim | fresh instance per pane, no socket |
| App bundle | `open Vimoire.app` | Neovide | double-click / Spotlight / `/Applications` |

## The bundle: clone-and-rebrand, not a wrapper

`bin/release` installs `~/Applications/Vimoire.app` by **cloning the installed
Neovide.app** (shipped inside the Homebrew keg) and rebranding it:

- `Info.plist`: `CFBundleName`/`CFBundleDisplayName` = Vimoire, `CFBundleIdentifier`
  = `dev.vimoire.app`, `CFBundleIconFile` = vimoire.
- `LSEnvironment`: `NVIM_APPNAME=vimoire` (loads the config, no wrapper script) and
  `NEOVIDE_ICON=<abs path to the bundle's icns>`.
- Neovide's `Neovide.icns` swapped for `vimoire.icns` (built by `bin/build-icon` from
  `assets/icon.png`).
- Re-signed ad-hoc (editing broke Neovide's ad-hoc/linker signature).
- The launcher CLI shipped at `Contents/Resources/vimoire` (self-detects app mode).

**Why clone instead of a wrapper `.app` that exec's neovide?** A wrapper makes macOS
attribute the app's identity — menu bar, Cmd-Tab, icon — to *Neovide.app* (the bundle
the binary physically lives in), so everything reads "neovide". Cloning makes the neovide
binary run *as* Vimoire.app, so `mainBundle` = Vimoire.app and the identity is really
"Vimoire". The wrapper's exec-into-Neovide's-inner-binary was also the source of the old
Neo-tree delay — **not reproduced** on Neovide 0.16.2 once we stopped wrapping.

**Why `NEOVIDE_ICON`?** Neovide re-applies its own icon at runtime, overriding
`CFBundleIconFile`. Handing it our icns via the env var is what actually shows the Vimoire
logo in the Dock/Cmd-Tab.

## Rebuilding

The bundle is a **copy of a specific Neovide version** — re-run `bin/release` after
every Neovide upgrade.

## Known seam

`NEOVIDE_ICON` is baked as an absolute path to `~/Applications/Vimoire.app`, so moving
the bundle elsewhere breaks the icon until you re-run `bin/release`.
