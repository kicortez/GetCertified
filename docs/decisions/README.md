# Decision log

Each file here is an architecture decision record (ADR): one decision, why it was made, what else was considered, and what it costs. Records are numbered in the order they were written and are never deleted once committed. If a decision changes, add a new record and set the old one's status to `Superseded by NNNN`.

Records 0001–0007 were written retroactively on 2026-11-25, from the code and commit history. Their dates are when the decision landed in the code. Records 0008–0010 came out of reviewing them that day, and haven't been implemented yet.

| # | Decision | Status |
|---|---|---|
| [0001](0001-rebuild-instead-of-port.md) | Rebuild in SwiftUI instead of porting the 2014 app | Accepted |
| [0002](0002-protocol-seam-on-every-service.md) | Put a protocol seam on every service, including static JSON | Accepted |
| [0003](0003-store-course-snapshots.md) | Store full course snapshots in the training list, not IDs | Superseded by 0008 (still in the code) |
| [0004](0004-cart-rules-in-service.md) | Keep cart rules in the service, not the controller | Accepted |
| [0005](0005-book-summary-at-top.md) | Put the Book summary at the top of the list | Accepted |
| [0006](0006-confirm-every-deletion.md) | Confirm every deletion from the training list | Superseded by 0010 (still in the code) |
| [0007](0007-test-controllers-and-on-device-logic.md) | Test controllers with fakes; test services only where they hold on-device logic | Accepted |
| [0008](0008-store-slim-cart-snapshots.md) | Store a slim snapshot of displayed fields in the training list | Accepted (not yet implemented) |
| [0009](0009-summary-in-service.md) | Compute the training summary in the service | Accepted (not yet implemented) |
| [0010](0010-remove-button-no-confirmation.md) | Remove trainings with a per-row button and swipe, without confirmation | Accepted (not yet implemented) |

"Superseded (still in the code)" means the replacement has been decided but not built yet, so the old record still describes how the app behaves today.

## Queued for implementation

One phase, since all of it touches `TrainingListService` and `BookView`:

- [0008](0008-store-slim-cart-snapshots.md): a slim snapshot type in Book, mapped from `Course` on add, with an empty-cart fallback when decoding fails.
- [0009](0009-summary-in-service.md): the service returns the list with its summary (count, hours, days at 8 hours per day). `BookView` and the Submit Request sheet stop calculating totals.
- [0010](0010-remove-button-no-confirmation.md): a per-row Remove button plus swipe, with no confirmation and no Edit mode.
- [0007](0007-test-controllers-and-on-device-logic.md): rewrite the `TrainingListService` and `TrainingListController` tests for the new API.

When an item ships, change its status to `Accepted` and update the superseded record's status note.

## Adding a record

1. Copy [`TEMPLATE.md`](TEMPLATE.md) to `NNNN-short-slug.md`, using the next number.
2. Fill it in. **Options** matters most: list the real alternatives, including "do nothing".
3. Add a row to the table above.
4. If it's one of the project's headline decisions, update the summary table in the root [`README.md`](../../README.md).

Write a record when a choice has a credible alternative and would be costly to reverse, or when someone reading the code later would ask "why is it like this?". Don't write one for routine conventions; those belong in `CLAUDE.md`.
