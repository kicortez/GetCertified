# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Get Certified" is a SwiftUI app for browsing training and certification courses and booking them. It has an app target (`GetCertified`) built for iPhone, iPad and visionOS (`TARGETED_DEVICE_FAMILY` 1,2,7), and a unit test target (`GetCertifiedTests`). Both deploy to iOS 18.0. There are no third-party dependencies and no lint config yet.

## Tests

`GetCertifiedTests/` uses Swift Testing (`import Testing`, `@Test`, `#expect`) with `@testable import GetCertified`. It is a synchronized folder for the test target and mirrors the feature folders (`Book/`, `Courses/`, `Home/`), with shared helpers in `Support/`: `Course.fixture(...)`, `TrainingListItem.fixture(...)`, `temporaryFileURL()`, and fake services (`Stub*Service` types that return a `Result`, `FailingTrainingListService`, `RecordingBookingService`). Test controllers through their service protocols. Test a service only when it holds logic that runs on the device (today only `TrainingListService`). Don't write tests for services that only load bundled JSON or mock a backend call, and don't write tests that assert on bundled content (see `docs/decisions/0007-test-controllers-and-on-device-logic.md`). Anything that writes to disk takes a temporary location, so tests never touch the app's real data.

Run them with the `GetCertifiedTests` scheme:

```bash
xcodebuild test -project GetCertified.xcodeproj -scheme GetCertifiedTests -destination 'platform=iOS Simulator,name=<simulator>'
```

No simulator is pinned. Pick an installed iPhone simulator from `xcrun simctl list devices available`; CI will choose its own.

The test target is hosted by the app. In `project.xcproj` it needs `test-host-target` and `dependencies` set to `GetCertified`, plus the `TEST_HOST` and `BUNDLE_LOADER` build settings. Without them it fails to link or to find the module on a clean build.

## Project file

The project uses Xcode 27's JSON project format (`GetCertified.xcodeproj/project.xcproj`), not a `project.pbxproj`. The `GetCertified/` folder is a synchronized folder reference, so a new `.swift` or resource file inside it joins the target automatically. Don't edit the project file to register files.

That automatic membership also covers non-code files. Every `CLAUDE.md` inside `GetCertified/` must be listed in the folder's `membership-exceptions` → `exclusions` in `project.xcproj`. If one isn't, it gets copied into the app bundle, and two of them make the build fail with "Multiple commands produce …/CLAUDE.md". `GetCertified/Info.plist` is excluded the same way. It is merged with the generated Info.plist (`INFOPLIST_FILE` + `GENERATE_INFOPLIST_FILE`) and holds only keys that build settings can't express, currently the `UILaunchScreen` dictionary (`AccentColor` background, `LaunchLogo` image). The app icon is `GetCertified/AppIcon.icon` (Icon Composer). After editing the project file, normalize it with `$(xcode-select -p)/usr/bin/xcprojformatter --update GetCertified.xcodeproj`.

## Compiler settings that affect how code is written

- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`: every type is implicitly `@MainActor`. Mark code `nonisolated` explicitly when it must run off the main actor.
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`, with Swift language mode 5.0.
- `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`: each file must import the module it uses members from, for example `import Observation` for `@Observable`.
- String catalogs are enabled (`LOCALIZATION_PREFERS_STRING_CATALOGS`, `SWIFT_EMIT_LOC_STRINGS`), so literal `Text("...")` strings get extracted for localization.

## Architecture

The code is organized by feature folder. `RootView` holds a `TabView` built with the `Tab` API, with three tabs: Home, Courses and Book.

Each feature folder has its own `CLAUDE.md`, which Claude Code loads when it works on files in that folder:

| Feature | Notes | Summary |
|---|---|---|
| Courses | `GetCertified/Courses/CLAUDE.md` | Course catalog. Uses View → Controller → Service layering and owns the `Course` model and `courses.json`. |
| Home | `GetCertified/Home/CLAUDE.md` | Landing tab: a hero banner, "Popular Courses" and "New Courses" rows, and a tip of the day. Each section has its own Controller → Service that reads bundled JSON in `Home/Resources/`. |
| Book | `GetCertified/Book/CLAUDE.md` | A training list the user builds from Courses, saved locally as JSON, with a "Submit Request" sheet that sends it through a mock booking service. Uses View → Controller → Service layering. |

The `Course` model belongs to Courses, but other features use it too. State shared across features lives in controllers that the `App` (`GetCertified.swift`) owns and injects with `.environment(_:)`. For now that is only `TrainingListController`, which "Add to training" in Courses writes to and Book reads from. Book saves its own `TrainingListItem` snapshot rather than `Course`.

New features should follow the Courses layering, and each new feature folder gets its own `CLAUDE.md`.

## Decision log

Architecture and product decisions are recorded as ADRs in `docs/decisions/` (see its `README.md` for the format and the index). When a change involves a choice with a credible alternative, or one that would be costly to reverse, propose a new record from `docs/decisions/TEMPLATE.md` as part of that change and add it to the index. Don't record routine conventions; they belong in the `CLAUDE.md` files. If a change reverses an existing record, write a new record and mark the old one `Superseded by NNNN`; don't edit its reasoning. `docs/` is outside the synchronized `GetCertified/` folder, so it needs no project-file exclusion.

## Conventions

- Use 2-space indentation.
- Prefer native SwiftUI components: `NavigationStack`, `ContentUnavailableView`, `.searchable`, `.confirmationDialog`, `@Observable` rather than `ObservableObject`.
- A view computes its derived values as private computed properties and splits its `body` into private `some View` subviews.
