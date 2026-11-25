# 0002: Put a protocol seam on every service, including static JSON

- **Status:** Accepted
- **Date:** 2026-11-19

## Context

All data is local today: the catalog and Home content are bundled JSON, the training list is a file, and booking is a mock. A backend is plausible but not planned. The app should still show where one would plug in, and controllers need to be testable without the bundle or the file system.

## Options

1. **Controllers read data directly** (`Bundle.main`, `FileManager`). Fewest types, but controllers can't be tested in isolation, and adding a backend means rewriting them.
2. **Concrete services that take their location as a parameter** (a `Bundle` or file URL), with no protocol. Tests point them at test data, the way `TrainingListService` already takes a file URL. This means fewer types, but a backend would still require changing every controller's dependency type.
3. **A protocol per service, injected through the controller's `init`.** Controllers depend on the protocol; production passes the real implementation, and tests pass fakes.

## Decision

Option 3, applied the same way to every data source. A single pattern is simpler to follow than deciding case by case which sources deserve a protocol. Each feature follows View → Controller → Service protocol → implementation. The protocol shows where a backend would sit, and it's what the tests fake (`Stub*Service`, `FailingTrainingListService`, `RecordingBookingService`).

Home has one service per section (hero, rows, tip) on purpose, so each section loads and fails on its own.

## Consequences

- More types than a JSON-only app strictly needs, especially in Home.
- Swapping in a backend changes only the service implementation and where it's constructed. No view or controller changes.
- Revisit if a protocol only ever has one real implementation *and* no fake uses it.
