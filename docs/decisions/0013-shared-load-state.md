# 0013: Share one generic LoadState across loading controllers

- **Status:** Accepted
- **Date:** 2026-11-25

## Context

0012 gave `CourseController` a nested `State` enum. Home's three controllers (`HeroBannerController`, `CourseRowController`, `TipController`) still exposed bare optionals or arrays and only `print`ed errors. The Home course rows load through `CourseService`, which now has a simulated 1-second delay, so they sat blank while loading and stayed blank after a failure, with no way to retry. Each controller loads exactly one value, so they all need the same three states.

## Options

1. **A nested enum per controller**, copying `CourseController.State`. Each controller is self-contained, but the same three cases get written four times and can drift apart.
2. **One generic `LoadState<Value: Codable>`** in `GetCertified/Shared/`, used by every controller that loads data. The cases are defined once, and views and tests handle every section the same way. The `Codable` constraint matches what services return today, which is decoded JSON.
3. **One whole-screen state for Home.** Simpler to show, but one failed section would blank the whole tab, and Try Again would reload everything.
4. **Do nothing.** Home failures stay invisible and untestable.

## Decision

Option 2, with a separate state for each Home section. A single generic type keeps every controller's states identical. Giving each section its own state means a failure stays in that section and Try Again reloads only what failed.

## Consequences

- `CourseController.State` is gone. Controllers declare `private(set) var state: LoadState<…> = .loading`.
- `LoadState` is `Equatable` only when `Value` is, so tests that compare states need an `Equatable` value.
- `Value` must be `Codable`. A controller that loads something non-`Codable` would need the constraint relaxed.
- `TrainingListController` and `SubmitRequestController` don't use it yet. `SubmitRequestController.Status` models a submit flow, not a load.
