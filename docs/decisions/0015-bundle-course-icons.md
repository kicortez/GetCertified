# 0015: Bundle course icons in the asset catalog

- **Status:** Accepted
- **Date:** 2026-11-26

## Context

Every course's `image` was the string `"placeholder"`, and `CourseDetailView` passed it to `AsyncImage` as if it were a URL, so no course had a picture. There are now 28 icons, one per course, as SVGs (with 256 px PNG exports). There is no backend to host them, and the catalog itself is already bundled JSON.

## Options

1. **Asset catalog, SVG with preserved vector data:** each icon is an image set under a namespaced `icons` folder, and `image` holds the asset name (`icons/<course-id>`). Icons stay sharp at any size, load synchronously and work offline. Adding a course means adding an asset and shipping an update.
2. **Asset catalog, PNG:** the same, but the 256 px PNGs look soft above about 85 pt on a 3x screen, and the detail view shows them larger than the cards do.
3. **Remote URLs through `AsyncImage`:** this matches the old model, but needs hosting, adds loading and failure states to every card, and the app has no backend.
4. **Do nothing:** every course keeps an empty tinted tile.

## Decision

Option 1. Images are stored locally for simplicity: the catalog is bundled, so its icons are too, and vector assets cover every size the views use.

## Consequences

- The `image` field is now an asset name, not a URL. `CourseIcon` (`Shared/CourseIcon.swift`) shows a tinted fallback tile when no asset matches, so a new course without an icon doesn't show a blank space.
- Icons are part of the app binary. If courses come from a server later, `image` would become a URL and `CourseIcon` would need a remote path (with this asset lookup kept as the fallback). That is the point to revisit.
- The icons use Lucide glyphs, so `docs/licenses/LUCIDE-LICENSE.txt` must stay with the project.
