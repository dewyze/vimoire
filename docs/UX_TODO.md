# UX TODO

Parked ideas requiring individual scoping. Each item is a starting point, not a spec.

---

## Writing Goals

Needs its own scoping session. Want some form of daily/weekly word count goal tracking — visible while writing, not just in stats. Could be a progress bar, end-of-session summary, or some combination of the items below.

---

## Deadline Pace Tracking

Add a `deadline` date to `book.yml` alongside `target_words`. Vimoire computes required words/day to hit the goal and surfaces it passively — statusline, stats float, or dashboard widget.

```yaml
goals:
  target_words: 80000
  daily_words: 1000
  deadline: "2025-11-30"
```

---

## Writing Streak / Activity Graph

Track consecutive days with at least N words written (configurable threshold, default ~100). Display options:

- A streak counter on the dashboard ("🔥 7 days")
- A GitHub-style contribution heatmap showing words-per-day over the past year
- Or both

Data derives from git history — auto-commit timestamps group by date into per-day word deltas, so no separate log file is needed. Needs its own scoping for computation and display.

---

## Timed Writing Sprints

A countdown timer for focused writing sessions. `:WriteSprint 25` starts a 25-minute sprint with a visible float or statusline indicator. Optional: shows words written during the sprint when it ends.

Pomodoro-style. Opt-in, no interruptions during the sprint itself.

---

## Split Notes / Chapter View

**Problem:** Notes end up at the bottom of the prose file as a workaround.

**Idea:** A keybinding that opens the chapter's `notes.md` in a vertical split alongside the prose. Focus mode (`:ViewFocus`) should close the notes split when activated.

**Scope:** keybinding, split lifecycle, focus mode integration.

---

## Git Extras

Auto-commit and `:GitCommit` shipped (see `docs/CONFIGURATION.md`, git section) — nothing to remember anymore. Parked follow-ons:

- Statusline indicator: time since last milestone commit
- `:GitLog` — picker over commit history with per-day word deltas (groundwork for writing stats)

---

## Writing Sounds

Typewriter keystroke sounds while writing. Neovide may support this via scripting. Opt-in, off by default.

---

## Revision / Track Changes

Post-draft-1. See `docs/REVISION_UX.md` for the full revision feature backlog.

---
