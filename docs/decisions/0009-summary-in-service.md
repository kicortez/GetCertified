# 0009: Compute the training summary in the service

- **Status:** Accepted
- **Date:** 2026-11-25

## Context

The Book summary shows the number of trainings, total hours and total days. Days follow a product rule: one training day is 8 hours. Today the totals are calculated in two places. `BookView` calculates count, hours and days, with `hoursPerDay = 8` as a view constant. `SubmitRequestController.totalHours` calculates hours again for the Submit Request sheet. Under [0004](0004-cart-rules-in-service.md), cart rules live in the service because a backend would own them, and the hours-per-day rule is one of those rules.

## Options

1. **Keep calculating in the views and controllers.** No changes, but the rule stays in UI code and the calculation stays duplicated.
2. **A shared helper on the client** (for example, an extension on `[Course]` or on the snapshot type). This removes the duplication, but the rule still lives in the app, not where a backend would own it.
3. **The service returns the list together with its summary** (for example, a `TrainingList` with `courses` and `summary`: count, hours, days). Views and controllers display the values without calculating them.

## Decision

Option 3. The summary follows a business rule, so it belongs with the other cart rules in the service, where a backend would take it over. It also gives the totals one source, so the Book tab and the Submit Request sheet can't disagree.

## Consequences

- The service API grows. `fetch`, `add` and `remove` return a `TrainingList` instead of a bare array, and the controller exposes the summary.
- The Submit Request sheet gets the summary passed in instead of calculating `totalHours` itself.
- Formatting (decimal places, singular and plural labels) stays in the views. Only the values come from the service.
- Implement together with [0008](0008-store-slim-cart-snapshots.md), since both change `TrainingListService`.
