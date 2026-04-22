# Todo

Parked work. Written so each item can be picked up cold without conversation context.

## Kinds-table refactor — active, branch `kinds_refactor`

Replace the 5 per-kind classes (`Chapter`, `Page`, `PlanningItem`, `ManuscriptSection`, `PlanningSection`) with a data-driven `core/kinds.lua` config table + a single `core/item.lua` class that reads from it. Drops `DocumentBase`/`SectionBase`/per-kind-class shims along the way.

**Full plan + rationale:** `docs/COMPOSITION.md`. Includes the kinds.lua shape, the 6-step migration sequence, per-step risk gates, and why we picked this shape over the originally-pitched component hybrid.

**Risk posture:** real but bounded. Step 3 (`Entry.build` switchover) is the integration moment — full state_spec pass + manual smoke test required. Halt-mid-refactor is the worst state, so each commit on the branch must be green and ship-able. Steps 1-2 are zero-risk (pure additions), step 3 is high-risk (semantic switch), steps 4-5 are low-risk (cleanup with tests as safety net).

### Items folded into this refactor

Don't tackle separately. These are covered by or directly adjacent to the kinds-table work:

- **`DocumentBase:destroy` silently creates a planning item from notes.** The "preserve notes on delete" behavior is tied to the current class hierarchy. Rethink during the migration — likely a `preserve_on_delete = true` flag in the kinds entry, or stays as logic on Item with no kind-flag (acts on presence of notes file).
- **Declarative synthetic-folder table in `state.lua`.** Synthetic folders (manuscript, planning, characters, etc.) constructed at rebuild time. Open question in COMPOSITION.md whether they fold into Item or stay as Folder. Decide during the migration.

