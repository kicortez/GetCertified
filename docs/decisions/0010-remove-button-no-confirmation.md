# 0010: Remove trainings with a per-row button and swipe, without confirmation

- **Status:** Superseded by [0011](0011-swipe-only-removal.md)
- **Date:** 2026-11-25

## Context

Under [0006](0006-confirm-every-deletion.md), every removal from the training list goes through a `confirmationDialog`, whether it starts from a swipe or from Edit mode. A review found problems with that setup. In Edit mode the user confirms twice: the minus button already shows a Delete button, and then the dialog asks again. The plural "Remove N courses?" title can never show, because the list has no multi-select. And because the catalog is small and searchable, re-adding a course removed by mistake is cheap. The confirmation was originally a UX default ("deletion should be confirmed"), not a response to a measured problem.

## Options

1. **Keep 0006:** confirm every deletion. Safe, but it adds friction to every removal and a redundant step in Edit mode.
2. **A per-row "Remove" button only.** One explicit path, with nothing to trigger by accident. It drops swipe-to-delete, which iOS users expect on a list like this.
3. **A per-row "Remove" button plus swipe-to-delete, neither confirmed.** The button makes removal discoverable, and swipe keeps the platform convention. Both act immediately.
4. **Delete immediately with undo.** Recoverable, but it needs a custom toast, or relies on `UndoManager`, which few users discover.

## Decision

Option 3. A labeled button is deliberate enough that no confirmation is needed, and swipe costs nothing to keep. Mistakes are cheap to recover from by re-adding the course from Courses. Edit mode goes away, along with `pendingDeletion`, the confirmation dialog, and Submit being disabled while editing.

## Consequences

- A mis-tap or a full swipe removes a course immediately, with no undo.
- There's no bulk removal. That's fine for lists of a few items. Revisit if multi-select is ever needed.
- The row's Remove button must be scoped to itself (`.buttonStyle(.borderless)`), so it doesn't take over the row's tap. This matters once Book rows navigate to course details.
- `BookView` and `Book/CLAUDE.md` lose their Edit-mode and confirmation sections.
