# 0003: Store full course snapshots in the training list, not IDs

- **Status:** Superseded by [0008](0008-store-slim-cart-snapshots.md) (still in the code until 0008 is implemented)
- **Date:** 2026-11-20

## Context

The training list (the Book tab's cart) is saved locally as JSON. It has to survive relaunches and show each course's name and hours, which the Book summary totals. "Add to training" in Courses already has the full `Course` value in hand, and `Course` is already `Codable`.

## Options

1. **Store course IDs and resolve them against the catalog.** The data is always current, but rendering the list depends on loading the catalog first, and a course that disappears from the catalog silently drops out of the cart.
2. **Store full `Course` snapshots.** Saving is a single `JSONEncoder` call, and the list renders without the catalog. Saved details can go stale.

## Decision

Option 2, because it was the simplest thing that worked. `Course` was already `Codable`, so the cart could persist `[Course]` directly. Booking only sends course IDs (`BookingRequest.courseIDs`), so a stale snapshot is never what the backend acts on.

## Consequences

- Saved hours and names can drift from the catalog, so the summary the user sees before submitting could show old values.
- The save format is the catalog's model. Adding a required field to `Course`, or renaming one, makes old saved carts fail to decode, so the user's cart is lost rather than just stale. This wasn't considered when the decision was made, and it led to [0008](0008-store-slim-cart-snapshots.md).
- Most of what's saved (description, category, image) is never read by Book.
