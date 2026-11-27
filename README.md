# Get Certified

A SwiftUI app for browsing training and certification courses and requesting to book them. It is a ground-up rebuild of the first iOS app I shipped, in 2014. The original Objective-C source is lost, so the only "before" is the App Store build. The full story is in the [case study](https://kicortez.github.io/case-studies/get-certified-revamp/).

**Platforms:** iPhone, iPad, visionOS · **Minimum:** iOS 18 · **Stack:** SwiftUI, Observation, Swift Testing · **Dependencies:** none

## What it does

| Tab | What the user does |
|---|---|
| **Home** | Sees a hero banner, "Popular" and "New" course rows, and a tip of the day. |
| **Courses** | Browses and searches the catalog, opens a course, and adds it to their training list. |
| **Book** | Reviews the training list, then submits one booking request with contact details and a preferred start date. A reference number comes back. |

In the old app, the inquiry form asked only for personal details. In the rebuild, the user collects trainings into a training list first, then sends one request that says what they want and when.

## Architecture

Each feature folder (`Home/`, `Courses/`, `Book/`) is layered the same way:

```
View  ──▶  Controller (@Observable)  ──▶  Service protocol  ──▶  implementation
                                                                  (bundled JSON, file, mock)
```

- **Views** own their controllers as `@State` and contain no data logic.
- **Controllers** are `@Observable` and hold the state a screen needs. Their service comes in through `init` behind a protocol.
- **Services** are the only code that touches data. Today that means bundled JSON, a local file and a mock booking endpoint. Each one is the place where a real backend would plug in, and no view or controller would have to change.
- **Shared state:** the training list is the only state that crosses features (Courses writes to it, Book reads from it). It lives in one `TrainingListController` that the `App` owns and injects with `.environment(_:)`.

Concurrency: the target uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so UI-facing types are main-actor by default, with no `@MainActor` annotations spread through the code. Anything that has to run off the main actor must be marked `nonisolated` explicitly.

## Key decisions

| Decision | Why | Tradeoff |
|---|---|---|
| [Rebuild in SwiftUI instead of porting](docs/decisions/0001-rebuild-instead-of-port.md) | The source was gone, and most findings were structural (navigation, layout, flow), not cosmetic. | The new app has no code lineage with the old one, so "before" can only be compared by behavior. |
| [Protocol seam on every service, including static JSON](docs/decisions/0002-protocol-seam-on-every-service.md) | Controllers can be tested with fakes, and a backend can be added without touching UI. | More types than a JSON-only app strictly needs. |
| [The training list stores a slim snapshot of each course, not IDs](docs/decisions/0008-store-slim-cart-snapshots.md) | The list renders without the catalog, a course removed from the catalog doesn't silently drop out of the list, and changes to `Course` can't break a saved list because Book saves only the fields it displays. | Saved details can go stale. It replaced storing full `Course` values ([0003](docs/decisions/0003-store-course-snapshots.md)). |
| [One shared `LoadState` for every loading controller](docs/decisions/0013-shared-load-state.md) | Each screen, and each Home section, is always in exactly one of loading, loaded or failed, so failures are visible, retryable and testable. A failed Home section fails on its own. | The value must be `Codable`, and views that need the last good value keep it themselves ([0014](docs/decisions/0014-training-list-failures.md)). |
| [Remove trainings by swipe only, without confirmation](docs/decisions/0011-swipe-only-removal.md) | Swipe-to-delete is the platform convention, and re-adding a course is cheap. | No undo, and removal is less discoverable. It replaced a confirmation dialog ([0006](docs/decisions/0006-confirm-every-deletion.md)) and a per-row button ([0010](docs/decisions/0010-remove-button-no-confirmation.md)). |

Every decision, with the alternatives that were considered, is recorded in the [decision log](docs/decisions/).

## Known limitations

These are deliberate cuts for now, listed so the gaps aren't a surprise:

- All data is local. The catalog, training list and booking services add a simulated delay so loading states show up as they would with a network.
- Training-list file I/O runs on the main actor. That's fine at this size, and it's the first thing to move off the main actor if the list grows.
- Booking goes to `MockBookingService`. No request leaves the device.
- Removing a training has no undo. A course removed by mistake is re-added from Courses.
- Course icons are bundled in the asset catalog, so a new course needs an app update ([0015](docs/decisions/0015-bundle-course-icons.md)).
- Tests run locally only. A CI workflow is planned.

## Tests

The tests use Swift Testing (`@Test`, `#expect`) and live in `GetCertifiedTests/`, which mirrors the feature folders. Controllers are tested through their service protocols with fakes from `Support/`. Services are tested only where they hold logic that runs on the device (today, the training list). Services that load bundled data or mock a backend call are stand-ins, so they aren't tested ([0007](docs/decisions/0007-test-controllers-and-on-device-logic.md)). Anything that writes to disk uses a temporary location.

```bash
xcodebuild test -project GetCertified.xcodeproj -scheme GetCertifiedTests \
  -destination 'platform=iOS Simulator,name=<simulator>'
```

Replace `<simulator>` with any installed iPhone simulator (`xcrun simctl list devices available`). In Xcode, run the `GetCertifiedTests` scheme with ⌘U.

## Building

Open `GetCertified.xcodeproj` in Xcode 27 or later. The project uses Xcode's JSON project format, and `GetCertified/` is a synchronized folder: a new file added there joins the target automatically.

## Working with AI

This app was built with Claude Code. I set the architecture, the conventions and the product decisions, and I reviewed every change before committing it. Two practices kept that review manageable:

- **Scoped context files:** the root [`CLAUDE.md`](CLAUDE.md) holds project-wide rules (isolation, project format, conventions). Each feature folder has its own `CLAUDE.md` describing that feature's layering and invariants, so the AI loads only the context for the code it's touching.
- **Small, reviewable commits:** work was done in phases, and each one stopped for my review before the next began. See the [commit history](https://github.com/kicortez/GetCertified/commits/main).
