# Commands Audit & Command Palette

## Summary

Audit all user commands, consider dropping the `Vimoire` prefix, and add a command palette for discoverability.

## Current Commands

All commands currently prefixed with `Vimoire`:
- `:VimoireHome` — go to dashboard
- `:VimoireFocus` — toggle focus mode
- `:VimoireFocusRedistribute` — recalculate margins
- `:VimoireExport` — run export
- `:VimoireExportConfig` — generate/update export config
- `:VimoireNavigate` — open navigator picker
- `:VimoireManuscript` — manuscript finder
- `:VimoireCharacters` — characters finder
- `:VimoireSettings` — settings finder
- `:VimoireReference` — reference finder
- `:VimoireExports` — exports finder
- `:VimoireSnippets` — snippets browser
- `:VimoireSnippetExtract` — extract selection as snippet
- `:VimoireNotes` — open notes for current entry
- `:VimoireMarks` — browse marks
- `:VimoireToggleKind` — toggle chapter/page
- `:VimoireInsertMark` — insert a mark
- `:VimoireInsertImage` — insert an image
- `:VimoireTheme` — change colorscheme

## Drop the Prefix?

Since vimoire is a standalone app with `NVIM_APPNAME=vimoire`, we control the command namespace entirely.

**Proposal:** Drop `Vimoire` prefix.
- `:Export` instead of `:VimoireExport`
- `:Focus` instead of `:VimoireFocus`
- `:Home` instead of `:VimoireHome`

**To verify:** Audit for collisions with vim built-ins or plugin commands. Likely safe since we control the environment.

## Command Palette

VS Code style: `<C-k>` (or similar) opens a fuzzy-searchable list of all commands.

### Implementation Options

1. **Snacks picker** — we already use snacks for pickers
2. **Telescope** — if we add it as dependency
3. **Custom float** — simple filtered list

### Palette Contents

- All user commands (`:Export`, `:Focus`, etc.)
- Theme switching
- Quick settings toggles
- Maybe recent files?

### UX

- Type to filter
- Enter to execute
- Preview/description for each command
- Group by category (Navigation, Export, Editing, etc.)

## Keymaps + Palette

**Approach:** Supplement, not replace.

- Common actions have dedicated keymaps AND appear in palette
- Rare actions may be palette-only (if keymap space is precious)
- Palette helps discoverability; keymaps help speed

Example: Export has both `<Leader>fe` (or whatever) AND `:Export` in palette.
