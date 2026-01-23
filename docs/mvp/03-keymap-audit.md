# Keymap/Hotkey UX Audit

## Summary

Audit all keymaps for UX consistency, discoverability, and intentional design. Vimoire is a standalone app — we control the keymap space and should use it deliberately.

## Current State

- Mix of `<Leader>` and `<LocalLeader>` without clear distinction
- `gv` prefix for view commands (gvh, gvf, gvm, gve)
- `<Leader>f` prefix for finder commands
- Organically evolved, needs cohesion

## Guiding Principles

1. **Domain grouping** — related commands share a prefix
2. **Mnemonics** — keys hint at function (f=find, e=export, n=navigator)
3. **Frequency** — common actions = fewer keystrokes
4. **Consistency** — similar actions use similar patterns across domains

## Display Lines vs Buffer Lines

Prose writing involves long soft-wrapped paragraphs. Standard vim commands operate on buffer lines (newline-delimited), but writers think in display lines (visual rows).

| Action | Buffer line (vim default) | Display line |
|--------|---------------------------|--------------|
| Move down | `j` | `gj` |
| Move up | `k` | `gk` |
| End of line | `$` | `g$` |
| Start of line | `0` | `g0` |
| Append at end | `A` | `gA` (custom) |
| Insert at start | `I` | `gI`? (to define) |

**Question:** Should prose buffers remap `j/k/$/0/A/I` to display line equivalents by default? We already do `j→gj` and `k→gk`. Consider extending to `A→g$a`, `I→g^i`, etc.

## Standard Shortcuts to Consider

- `<C-p>` — find files (common in many editors)
- `<C-k>` — command palette (VS Code convention)
- `<C-s>` — save (universal, though vim has `:w`)
- `<C-f>` — search in file

## Discoverability

Options:
1. **Command palette** — searchable list of all commands (see 04-commands-audit.md)
2. **Which-key style hints** — show available keys after prefix
3. **Help docs** — comprehensive but requires reading
4. **Cheat sheet** — quick reference overlay

## Audit Scope

Inventory all current keymaps:
- Finder keymaps (`<Leader>f*`)
- Navigator keymaps (`<LocalLeader>n*`, `gv*`)
- Buffer keymaps (`<Leader>N`, `<Leader>M`, etc.)
- Editing keymaps (`gA`)
- View keymaps (`gvh`, `gvf`, `gvr`)
- Snippet keymaps
- Image keymaps

Then propose a unified scheme with rationale.
