# 0007: Test controllers with fakes; test services only where they hold on-device logic

- **Status:** Accepted
- **Date:** 2026-11-24

## Context

Under [0002](0002-protocol-seam-on-every-service.md), every controller gets its service through a protocol, and most services are stand-ins for backend calls: `CourseService` and the Home services load bundled JSON, and `MockBookingService` fakes the booking request. A backend would replace them, so testing them would mostly test the bundled content or the mock. What matters on the client is how controllers handle a service's result.

`TrainingListService` is the exception. Under [0004](0004-cart-rules-in-service.md), it holds logic that runs on the device: the cart rules (no duplicates, removal) and the saved file.

## Options

1. **Test services against the app's bundled JSON.** This catches content mistakes, such as a Home row ID missing from the catalog, but it tests data rather than code, and the tests break when content is edited.
2. **Test services against fixture JSON.** The tests wouldn't depend on content, but `BundledJSON` reads only from the main bundle, and the services are stand-ins that a backend would replace.
3. **No service tests at all.** This is the simplest option, but it leaves the training list's on-device logic untested.
4. **Test controllers through fakes, and test only the services that hold on-device logic** (today only `TrainingListService`).

## Decision

Option 4. Tests cover client behavior: controllers through their protocols, using the fakes in `GetCertifiedTests/Support/`, and the one service whose logic stays on the device. Anything that writes to disk uses a temporary location.

## Consequences

- Mistakes in the bundled content aren't caught by tests. A Home row ID that's missing from the catalog shows up only as a missing card at runtime.
- When a real backend replaces a stand-in service, its contract should be covered there, or with contract tests.
- The tests will run in CI. A GitHub Actions workflow is planned.
