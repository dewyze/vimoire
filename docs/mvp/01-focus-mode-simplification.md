# Focus Mode Simplification

## Summary

Simplify focus mode by moving it from a separate `margins/` plugin into vimoire proper, and removing unnecessary complexity around window recalculation.

## Current State

- Focus mode lives in `app/lua/margins/` as a separate plugin
- Has logic to recalculate margins when windows change
- Interacts awkwardly with neotree in some edge cases

## Desired Behavior

1. **Ignore neotree entirely** — focus mode sets the main editing window to the target width (e.g., 86 columns). Opening/closing neotree should not affect this.

2. **No recalculation** — when in focus mode, don't recalculate margins on window events. The focused window stays at its width regardless of what else opens.

3. **Simple model**: "set window width to X, pad the rest with readonly buffers"

## Implementation

- Move `margins/` logic into `vimoire/focus.lua` (or merge with existing)
- Remove window-change recalculation hooks
- Simplify to: enter focus → set width → done
- Exit focus → restore normal window behavior

## Bug: Padding Windows Block Navigation

`<C-w>l` from neotree → prose works fine, but `<C-w>h` from prose → neotree does not. Something is blocking leftward navigation, possibly:
- A keymap override in the padding window
- The padding window intercepting and not passing through
- Focus mode setup blocking it

**Fix:** Investigate and ensure `<C-w>h/j/k/l` pass through padding windows to reach neotree or other real windows.

## Why

- Vimoire is a standalone app — no need for margins as a reusable plugin
- Logic is getting simpler, not more complex
- Reduces indirection and maintenance burden
