# Vimoire — book.yml Spec

Refactor to introduce `book.yml` as the user-facing book identity file.

---

## Overview

Currently `manuscript.json` holds both structural state (items, ordering, IDs) and book identity (title, description). This refactor separates concerns:

- **book.yml** — User-facing identity file. Title, description, author, publishing metadata. Editable, visible in sidebar.
- **manuscript.json** — Internal app state. Structure, ordering, IDs. Hidden from users.

---

## book.yml Schema

```yaml
title: "The Unreliable Memoirs of Gerald the Sentient Toaster"
description: "A toaster gains sentience and has feelings about bread."
author: "Author Name"
language: en

# Optional publishing metadata (uncomment when needed)
# copyright: "© 2025 Author Name"
# publisher: "Publisher Name"
# isbn: "978-0-000000-00-0"
```

**Required fields:**
- `title` — Book title, used in exports and UI
- `author` — Author name for exports

**Optional fields:**
- `description` — Book description/blurb
- `language` — Language code (default: `en`), used for EPUB metadata and HTML lang attribute
- `copyright` — Copyright notice for front matter
- `publisher` — Publisher name for metadata
- `isbn` — ISBN for published works

---

## Neotree Placement

book.yml appears at the top of the navigator, above Manuscript:

```
📖 Book Info          ← book.yml (shows title from file)
📚 Manuscript
   └── Part 1
       └── Chapter 1...
👤 Characters
🌍 Settings
📑 Reference
```

**Node behavior:**
- Display: Shows book title (read from book.yml)
- Action: Opens book.yml for editing
- Icon: Book or info icon to distinguish from manuscript content

---

## Refresh on Save

When book.yml is saved, refresh the neotree node to reflect any title change:

```lua
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "book.yml",
  callback = function()
    -- Refresh neotree book node (implementation TBD based on neotree source)
  end,
})
```

---

## Migration

**manuscript.json before:**
```json
{
  "id": "bk2xqr",
  "title": "Gerald the Sentient Toaster",
  "description": "A toaster story.",
  "items": [...]
}
```

**manuscript.json after:**
```json
{
  "id": "bk2xqr",
  "items": [...]
}
```

**New book.yml:**
```yaml
title: "Gerald the Sentient Toaster"
description: "A toaster story."
author: "Author Name"
language: en
```

---

## Code Changes

### Reads to update

Anywhere reading `title` or `description` from manuscript.json needs to read from book.yml instead:

- Export pipeline (reads title for output filename, metadata)
- UI displays showing book title (if any)
- Any future features using book metadata

### Scaffold changes

Project scaffolding creates book.yml with placeholder content:

```yaml
title: "Untitled"
description: ""
author: "Author Name"
language: en
```

### Neotree source changes

Add book.yml node to the navigator tree, above the manuscript root.

---

## Implementation Steps

1. [ ] Add book.yml to scaffold template
2. [ ] Create `vimoire.book` module to read/parse book.yml
3. [ ] Update manuscript.json handling to remove title/description
4. [ ] Add book node to neotree source (top of tree)
5. [ ] Add BufWritePost autocmd for book.yml refresh
6. [ ] Update any code reading title/description from manuscript.json

---

## Open Questions

None currently.
