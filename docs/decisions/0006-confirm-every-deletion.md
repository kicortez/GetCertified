# 0006: Confirm every deletion from the training list

- **Status:** Superseded by [0010](0010-remove-button-no-confirmation.md)
- **Date:** 2026-11-19

## Context

Courses can be removed from the training list by swiping, or with Edit mode. A swipe is easy to trigger by accident, and re-adding a course means finding it again in Courses.

## Options

1. **Delete immediately.** This is the standard list behavior and the fastest, but an accidental swipe loses the item.
2. **Delete immediately and offer Undo.** This is fast and recoverable, but SwiftUI has no built-in toast or snackbar, so it would need a custom component.
3. **Confirm with a `confirmationDialog`.** It's native and costs one extra tap.

## Decision

Option 3. Every deletion goes into `pendingDeletion` first and is confirmed. It uses a native component and covers both the swipe and the Edit-mode paths with one code path.

## Consequences

- One extra tap for intentional removals.
- Revisit if users remove items often. Undo would then be the better experience.
