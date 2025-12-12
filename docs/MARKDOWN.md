# Vimoire — Markdown & Prose Format

Research notes on markdown compatibility, paragraph formatting, and export pipeline.

---

## Non-Negotiables

1. **Tab indentation** — Paragraphs must start with a visible tab indent. Essential for distinguishing dialogue from narration at a glance. No-tab or space-indent approaches are rejected.

2. **Clean editor experience** — No visible blank lines between paragraphs. Prose should look like prose, not markdown source.

3. **Proper export** — Each paragraph becomes a `<p>` tag in export. Dialogue lines are separate paragraphs, not `<br>` breaks within one paragraph.

---

## The Core Problem

**Standard markdown interprets tab-indented lines as code blocks.**

This creates cascading issues:
- Treesitter highlights tab-indented prose as code (blue)
- Pandoc would export tabs as `<pre><code>` blocks
- The format we want (tabbed paragraphs) fights markdown's design

---

## Paragraph Conventions

### What We Want

```
    First paragraph with tab indent. If it is a really long line, like this one, then eventually with enough words it will just wrap to the next line and you will see how that works.
	  Second paragraph, no blank line between.
	  "Dialogue works the same way," she said.
	  "Each line is its own paragraph," he replied.
```

### What Standard Markdown Wants

```
First paragraph, no indent.

Second paragraph, blank line required.

"Dialogue works the same way," she said.

"Each line is its own paragraph," he replied.
```

---

## Export Pipeline

**Solution:** Preprocess before pandoc.

Transform our format → standard markdown → pandoc:

```ruby
content
  .gsub(/^\t/, '')           # Strip leading tabs
  .gsub(/\n(?!\n)/, "\n\n")  # Single newline → double newline
```

**Result:** Pandoc sees clean markdown with proper paragraph breaks. Our tabs and single newlines are our editor convention, not what pandoc processes.

**Scene breaks:** Use `***` not `---`. Without blank lines around it, `---` can be parsed as a setext heading underline. `***` is unambiguous.

---

## Treesitter / Syntax Highlighting

**Problem:** Even with export solved, treesitter's markdown parser sees tab-indented lines as `indented_code_block` nodes and highlights them as code (blue).

### Options

| Approach | Effort | Notes |
|----------|--------|-------|
| Override highlights | Low | Create `queries/vimoire_prose/highlights.scm` that doesn't highlight code blocks. Parser still thinks it's code, but no visual difference. |
| Custom tree-sitter grammar | High | Fork markdown grammar, remove indented code block rule. Correct but maintenance burden. |
| No treesitter | Medium | Use vim regex syntax highlighting. Full control, but manual syntax file. |
| Accept it | None | Live with blue highlighting. Functional but ugly. |

**Recommended:** Override highlights first (low effort). If that causes other issues (concealing not working in "code blocks", etc.), escalate to custom grammar or vim syntax.

### Unknowns to Verify

- Does concealing work inside treesitter code block nodes?
- Do text objects / motions behave correctly?
- Are there other treesitter features that would misbehave?

---

## Paragraph Navigation

**`{` and `}` vim motions** jump to blank lines (paragraph boundaries).

- With blank lines between paragraphs: `{`/`}` works
- Without blank lines: `{`/`}` jumps to file boundaries (useless)

**Trade-off:** Clean editor (no blank lines) loses paragraph navigation. Visible blank lines enable it.

**Possible workaround:** Custom mappings that jump by tab-indented lines instead of blank lines. Would need to implement.

---

## Format Summary

Vimoire uses "prose markdown" — a variant where:

| Feature | Standard Markdown | Vimoire Prose |
|---------|-------------------|---------------|
| Paragraph separator | Blank line (`\n\n`) | Single newline (`\n`) |
| Paragraph indent | None | Tab (`\t`) |
| Scene break | `---` or `***` | `***` only |
| Inline formatting | `*italic*`, `**bold**` | Same |
| Headers | `# Title` | Same |

The files are `.md` and mostly portable. Export preprocessing normalizes to standard markdown.

---

## Related Decisions

- **autoindent enabled** — Enter preserves tab indent from current line
- **Soft wrap** — `wrap=true`, `linebreak=true`, `textwidth=0`
- **No hard line breaks** — Export uses `hard_line_breaks` extension if in-paragraph breaks are needed (Shift+Enter use case, currently deferred)

---

## Open Questions

1. **Single vs double newlines in editor** — Currently specced as single (no visible blank lines). Test fixtures have both for comparison. Final decision pending hands-on testing.

2. **Treesitter highlighting fix** — Need to spike the highlights.scm override to verify it works and doesn't break concealing.

3. **Custom paragraph navigation** — If we commit to no blank lines, should we implement custom `{`/`}` mappings?

---

## Test Fixtures

For comparison testing:

- `tests/fixtures/standard/entries/chap1a/prose.md` — Single newlines (no blank lines)
- `tests/fixtures/standard/entries/chap2a/prose.md` — Double newlines (blank lines between paragraphs)

Open both in vimoire to compare feel.
