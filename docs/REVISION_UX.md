# Revision UX

Features aimed at the revision/editing phase. Don't build these during draft-1 — scope them when the revision workflow becomes real.

---

## Sentence Focus Mode

Dim everything in the buffer except the current sentence (or paragraph). Different from whole-file focus mode — this is for slow, deliberate self-editing passes.

**Implementation:** extmarks to apply a dimmed highlight to all text outside the current sentence. Tree-sitter can identify sentence boundaries, or a simpler heuristic (`.!?` delimiters) may be enough.

**Toggle:** separate keybinding or a sub-mode of focus mode.

---

## Word Overuse Highlight

Scan the current chapter for words repeated more than N times and highlight them with a subtle color. "Gaze" appearing 12 times. "Just" everywhere.

**Scope:** buffer-local, opt-in toggle. Configurable threshold. Could also include a "weasel words" list (very/really/just/that/quite/somehow) flagged regardless of frequency.

---

## LanguageTool Integration

Open-source grammar and style checker. Runs as a local server (Java) or via their hosted API. Has an LSP implementation (`ltex-ls`) that Neovim already knows how to talk to.

Checks: grammar, punctuation, style, passive voice, redundancies. Supports many languages.

**Integration:** wire it in as an opt-in LSP that activates only in vimoire prose buffers. Toggle on/off — not always-on during draft.

See also: `ltex-ls` on GitHub for the LSP implementation.

---

## Track Changes / Beta Reader Feedback

When revision time comes, may need to ingest Word `.docx` track changes from beta readers or editors and view them in context inside Vimoire. Needs real scoping once the revision workflow is defined.

---
