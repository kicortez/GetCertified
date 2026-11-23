# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Get Certified" is a SwiftUI app for browsing training and certification courses and booking them. It is a single app target (`GetCertified`) built for iPhone, iPad and visionOS (`TARGETED_DEVICE_FAMILY` 1,2,7). The target's deployment target is iOS 18.0. There are no third-party dependencies, no test target and no lint config yet.

## Project file

The project uses Xcode 27's JSON project format (`GetCertified.xcodeproj/project.xcproj`), not a `project.pbxproj`. The `GetCertified/` folder is a synchronized folder reference, so a new `.swift` or resource file inside it joins the target automatically. Don't edit the project file to register files.

That automatic membership also covers non-code files. Every `CLAUDE.md` inside `GetCertified/` must be listed in the folder's `membership-exceptions` → `exclusions` in `project.xcproj`. If one isn't, it gets copied into the app bundle, and two of them make the build fail with "Multiple commands produce …/CLAUDE.md". After editing the project file, normalize it with `$(xcode-select -p)/usr/bin/xcprojformatter --update GetCertified.xcodeproj`.

## Compiler settings that affect how code is written

- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`: every type is implicitly `@MainActor`. Mark code `nonisolated` explicitly when it must run off the main actor.
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`, with Swift language mode 5.0.
- `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`: each file must import the module it uses members from, for example `import Observation` for `@Observable`.
- String catalogs are enabled (`LOCALIZATION_PREFERS_STRING_CATALOGS`, `SWIFT_EMIT_LOC_STRINGS`), so literal `Text("...")` strings get extracted for localization.

## Architecture

The code is organized by feature folder. `RootView` holds a `TabView` built with the `Tab` API, with three tabs: Home, which shows placeholder sections; Courses; and Book.

Each feature folder has its own `CLAUDE.md`, which Claude Code loads when it works on files in that folder:

| Feature | Notes | Summary |
|---|---|---|
| Courses | `GetCertified/Courses/CLAUDE.md` | Course catalog. Uses View → Controller → Service layering and owns the `Course` model and `courses.json`. |
| Home | `GetCertified/Home/CLAUDE.md` | Landing tab with placeholder sections: a hero banner, "Popular Courses" and "New Courses" rows, and a tip of the day. It has no data layer yet. |
| Book | `GetCertified/Book/CLAUDE.md` | A cart of trainings the user added, saved locally as JSON, with a "Submit Request" action (still TODO). Uses View → Controller → Service layering. |

The `Course` model belongs to Courses, but other features use it too. State shared across features lives in controllers that the `App` (`GetCertified.swift`) owns and injects with `.environment(_:)`. For now that is only `BookController`, which "Add to training" in Courses writes to and Book reads from.

New features should follow the Courses layering, and each new feature folder gets its own `CLAUDE.md`.

## Conventions

- Use 2-space indentation.
- Prefer native SwiftUI components: `NavigationStack`, `ContentUnavailableView`, `.searchable`, `.confirmationDialog`, `@Observable` rather than `ObservableObject`.
- A view computes its derived values as private computed properties and splits its `body` into private `some View` subviews.
