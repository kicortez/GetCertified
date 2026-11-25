# 0012: Model the course catalog load as a single state enum

- **Status:** Accepted
- **Date:** 2026-11-25

## Context

`CourseController.fetchCourses()` caught errors and only `print`ed them. The controller exposed a bare `courses` array, so the Courses tab showed a blank grid while it loaded and the same blank grid after a failure, with no way to retry. Tests could only assert that the array was empty, which looks the same for "still loading", "failed" and "loaded an empty catalog". `SubmitRequestController` already models its flow with a `Status` enum.

## Options

1. **Separate properties** (`isLoading`, `errorMessage`, `courses`). Familiar and simple to bind, but it allows combinations that make no sense (loading with an error, or courses alongside an error), and every view and test has to check several flags in the right order.
2. **One `State` enum with associated values** (`.loading`, `.success([Course])`, `.error(String)`). Only valid states can exist, the view switches on a single value, and a test asserts on a single value.
3. **Do nothing.** Failures stay invisible to the user and untestable beyond "the array is empty".

## Decision

Option 2. A single enum makes the controller predictable, since it is always in exactly one state, and testable, since each outcome is a distinct value to assert on. It also matches `SubmitRequestController.Status`.

## Consequences

- `CoursesView` switches on `state` and has a view for each case: a spinner, the grid, an empty-catalog view, and an error view with Try Again. Search is attached only to the grid, so it shows only when there are courses to search.
- Courses are read from `.success` instead of from a plain property. Any new consumer has to unwrap the state.
- `fetchCourses()` sets `.loading` first, so a retry goes through the same states. A refresh replaces the grid with the spinner. If pull-to-refresh is added, keeping the old courses during a reload would need another case or an associated value.
- Home and `TrainingListController` still only log their errors. They can adopt the same pattern later.
