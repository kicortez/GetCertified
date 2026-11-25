# 0004: Keep cart rules in the service, not the controller

- **Status:** Accepted
- **Date:** 2026-11-20

## Context

The training list has rules: adding a course that's already in the list does nothing, and removing deletes every match. Today the list is a local file. With a backend, the server would enforce these rules and return the resulting list, and the service is where that call would be made.

## Options

1. **The controller owns the rules,** computes the new list, and asks the service to save it. This can stay consistent with storage (assign only after a successful save), but the rules live in UI-facing code and have to move when a backend takes them over.
2. **The service owns the rules.** `add(_:)` and `remove(ids:)` apply the change, persist it, and return the updated list. The controller only forwards the call and assigns the result.

## Decision

Option 2. The service stands in for the backend, so the rules belong there. Adding a backend moves them out of the app along with the storage, and the controller doesn't change. The protocol exposes only the operations a backend would offer (fetch, add, remove). Saving is an internal detail, so `save(_:)` should be private to the service.

## Consequences

- `save(_:)` is still on the protocol and in `FailingTrainingListService`. Making it private is queued with [0008](0008-store-slim-cart-snapshots.md).
- Every change is a full read-modify-write of the file. That's fine for a handful of courses, but it wouldn't scale to large lists.
- The controller repeats the duplicate check (`contains(_:)`) so the UI can show "Added". That copy is only for display; the service still enforces the rule.
- Add and remove failures are only logged. User-facing error handling is deferred, like the other load failures listed in `README.md` → Known limitations.
- The file I/O currently runs on the main actor (see `README.md`, Known limitations). Moving it off would mean making the service an `actor`, or marking it `nonisolated`.
