# Development

## Dev/Stable split

Vimoire runs as two isolated builds on the same machine:

| Build  | Config dir             | Source                | Used for           |
|--------|------------------------|-----------------------|--------------------|
| Stable | `~/.config/vimoire/`   | frozen copy of `app/` | actual writing     |
| Dev    | `~/.config/vimoire_dev`| symlink → `app/`      | hacking on Vimoire |

Each build is fully isolated because `NVIM_APPNAME` scopes all Neovim data dirs automatically:

- Plugins: `~/.local/share/<appname>/lazy/` (dev's first launch reinstalls plugins)
- User prefs (runtime state): `~/.<appname>/` — resolved by `preferences.lua`
- User config (edited by user): `~/.vimoire/config.lua` is shared between builds by convention. Override by symlinking if you want them separate.

**Why the split:** stable is a frozen copy, so editing files in the repo — including checking out a feature branch — can't break your active writing session. Dev symlinks the live repo so iteration is immediate.

## Launchers

- `bin/vimoire` — stable. Sets `NVIM_APPNAME=vimoire`.
- Dev launcher lives outside this repo (in personal dotfiles) and sets `NVIM_APPNAME=vimoire_dev`.

## Releasing to stable

After merging work to `main`:

```bash
bin/release
```

Refuses to run if `app/` has uncommitted or untracked changes, or if the current branch isn't `main`. (Uncommitted changes outside `app/` — docs, PLAN files, etc. — don't block a release.) Rsyncs `app/` → `~/.config/vimoire/` with `--delete` (removes files that no longer exist in source). Writes the current SHA to `~/.config/vimoire/.release-sha`.

Your stable Neovim session won't see the change until you restart it.

## Rollback

`bin/release` is just an rsync. To roll back to a previous state:

```bash
git checkout <previous-sha>
bin/release    # will fail the "on main" check — expected, see below
```

The script refuses non-main branches to prevent accidental releases from feature branches. For a real rollback: reset main (or revert the offending commit) and re-release, so history stays honest.

## First-time setup on a new machine

```bash
git clone https://github.com/dewyze/vimoire ~/dev/vimoire
cd ~/dev/vimoire

# Stable (frozen copy of current main)
mkdir -p ~/.config
cp -R app ~/.config/vimoire
git rev-parse HEAD > ~/.config/vimoire/.release-sha

# Dev (symlink to repo)
ln -s ~/dev/vimoire/app ~/.config/vimoire_dev

# Add bin/ to PATH, or symlink bin/vimoire
ln -s ~/dev/vimoire/bin/vimoire /usr/local/bin/vimoire
```

## Key files

- `bin/vimoire` — stable launcher
- `bin/release` — promote `main` to stable
- `~/.config/vimoire/` — stable config dir (real copy)
- `~/.config/vimoire/.release-sha` — SHA currently released
- `~/.config/vimoire_dev` — dev config dir (symlink to `app/`)
- `app/lua/vimoire/preferences.lua` — defaults prefs dir to `~/.$NVIM_APPNAME` so the two builds don't stomp each other
