# macOS App Bundle — Status

Reference for revisiting native Mac app distribution.

## Current state

Vimoire ships as a launcher script, not a bundle:

```bash
# bin/vimoire
NVIM_APPNAME=vimoire ${VIMOIRE_EDITOR:-neovide} "$@"
```

Users install via Homebrew (or manually) and run `vimoire` from their shell.

## What was tried

| Commit | Date | What |
|--------|------|------|
| `447547b` | 2026-01-23 | Added `platform/macos/Vimoire.app/` bundle, `bin/build-icon`, `docs/HOMEBREW.md`, `docs/mvp/macos-app.md`, icon assets |
| `14c790e` | 2026-01-26 | Ripped the bundle out, replaced with `bin/vimoire` launcher script |

## Why the bundle was removed

From `14c790e` commit body:

> Neovide has a multigrid rendering bug when running under a foreign bundle context (any app bundle that isn't Neovide's own). This caused 5+ second delays when opening/closing Neo-tree.

A "foreign bundle context" means: a `.app` bundle whose `MacOS/<binary>` is not Neovide itself — e.g. a wrapper bundle that exec's `neovide` inside. Neovide detects it's running under a different bundle and triggers the multigrid path, which has the perf bug.

## What's still in the repo (orphaned)

These reference the deleted bundle and need either revival or cleanup:

- `bin/build-icon` — PNG → icns converter
- `bin/build-release` — Homebrew release packager (references deleted `platform/macos/Vimoire.app/`)
- `docs/HOMEBREW.md` — cask plan; references deleted paths and `docs/mvp/macos-app.md` (also deleted)
- `assets/icon*` — icon source files

## What changed since removal

- **Neovide `--icon` flag is now in stable** (was nightly-only at time of HOMEBREW.md writing). Setting a Dock icon no longer requires bundling.
- **Multigrid bug status: unknown.** Needs verification before any new bundle attempt. If still present, bundling Neovide is a non-starter regardless of icon support.

## Paths forward (when we revisit)

1. **Verify multigrid bug.** Build a minimal `.app` that exec's `neovide` and time Neo-tree open/close. If <500ms, bug is fixed.
2. **If fixed:** restore `platform/macos/Vimoire.app/`, update `bin/build-release`, refresh `docs/HOMEBREW.md`.
3. **If still broken:** consider alternatives:
   - Use `--icon` flag in the launcher script for Dock icon (no bundle needed, but no `/Applications` presence).
   - Ship a `.app` whose `MacOS/vimoire` runs the launcher in Terminal (loses Neovide entirely).
   - Wait for upstream fix.

## Open questions

- Is there a Neovide flag (newer than `--icon`) that explicitly opts out of the multigrid path under a foreign bundle? Worth checking release notes.
- Does the bug also affect the launcher-script-launched-from-Dock-shortcut path, or only true bundle exec?
