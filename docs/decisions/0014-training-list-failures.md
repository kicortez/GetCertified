# 0014: Drive every training list call through LoadState; views keep the last loaded list

- **Status:** Accepted
- **Date:** 2026-11-26

## Context

0013 moved every loading controller onto `LoadState`, except `TrainingListController`. That controller only `print`ed errors, and `TrainingListService` turned an unreadable file into an empty list. Book had no loading state, and every failure was invisible. The service is meant to stand in for a backend, so it should fail the way one would: with a user-facing error and some latency. Unlike the other controllers, this one also changes its value (add and remove) while the list is on screen. `LoadState.loading` carries no value, so setting it drops the list the user is looking at.

## Options

1. **`LoadState` for `fetch()` only, plus an `isProcessing` flag and an `actionError` for add and remove.** The list stays in `state`, but the controller has three outputs to keep in sync.
2. **Every call sets `.loading` → `.success`/`.error`; views keep the last `.success` list in their own `@State`.** One output from the controller. Each view that shows the list stores what it needs, so `.loading` and `.error` never clear the screen.
3. **Give `LoadState.loading` an associated previous value.** Keeps the value in one place, but changes the shared type and every controller and view that uses it.
4. **Keep printing.** Failures stay invisible and untestable.

For an unreadable saved file:

1. **Keep returning an empty list.** Silent data loss, unlike a backend.
2. **Throw from every call.** True to a backend, but a corrupt local file would block the list for good, because every call reads it.
3. **Throw from `fetch()`; add and remove start a new list.** The user sees the error, and their next change recovers.

## Decision

Option 2 for state, and option 3 for unreadable files. The controller has a single state that matches the other controllers, and keeping the last list is a display concern, so it belongs in the views that display it. Letting changes overwrite a bad file keeps the error visible without trapping the user.

## Consequences

- `TrainingListController` exposes only `state`; there is no `list`, `items` or `contains`. `BookView` keeps `list`, and `CourseDetailView` keeps `isAdded`, each set from `.onChange(of: state, initial: true)`.
- A view shows an alert only for a change it started (it checks `state` after awaiting the call), so one failure doesn't raise alerts in several tabs. A view opened while `state` is `.loading` or `.error` has nothing kept yet; `CourseDetailView` then shows "Add to training" until the next success.
- `TrainingListService` throws `ServiceError` (`.unreadable`, `.saveFailed`) and sleeps 1s per call, so tests that use the real service are about 1s slower per call.
- `TrainingList` and `Summary` are `Codable`, as `LoadState` requires.
- `SubmitRequestView` doesn't report a failed clear after a successful submit.
