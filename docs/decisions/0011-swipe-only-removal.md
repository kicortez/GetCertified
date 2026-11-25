# 0011: Remove trainings by swipe only, without confirmation

- **Status:** Accepted
- **Date:** 2026-11-25

## Context

[0010](0010-remove-button-no-confirmation.md) chose a per-row "Remove" button plus swipe-to-delete, neither confirmed. Once it was built, the button turned out to duplicate swipe-to-delete, the standard iOS way to remove an item from a list like this one. It also put a red button on every row of a short list.

## Options

1. **Keep 0010:** a Remove button plus swipe. Removal is easy to discover, but every row carries a second control that does the same thing as swipe.
2. **Swipe-to-delete only, not confirmed.** It follows the platform convention, with one way to remove and no extra controls on the rows.
3. **Swipe plus an Edit mode** for users who don't know about swipe. Edit mode was removed in 0010 because, with its own Delete button, it added a step without adding anything.

## Decision

Option 2. Swipe-to-delete is the iOS convention for lists, so a visible button on every row only duplicates it. Removal still happens immediately, as 0010 decided: a course removed by mistake is cheap to re-add from Courses.

## Consequences

- Removal is less discoverable for users who don't know swipe-to-delete. Revisit if that turns out to be a problem, for example with a context menu.
- A full swipe still removes a course immediately, with no undo.
- `TrainingListController` loses `remove(_:)`, which only the button used. Views remove items with `remove(ids:)`.
- 0010's note about scoping the row button with `.buttonStyle(.borderless)` no longer applies. Book rows can navigate to course details without that conflict.
