# 0001: Rebuild in SwiftUI instead of porting the 2014 app

- **Status:** Accepted
- **Date:** 2026-11-18

## Context

Get Certified was first shipped in 2014 as an Objective-C app. It is still live on the App Store but has not been updated since then, and its current usage is unknown (probably low). The original source is lost; the only reference is the App Store build. A review of that build found problems that are mostly structural: navigation relied on a Home button, the app didn't fill the screen, browsing the catalog was dated, and the inquiry form asked only for personal details, not what the user wanted to book.

With no source, a rewrite was the only real path. A "port" would have meant recreating screens that the review had already marked for redesign. So the open questions were which UI framework to use and which iOS version to set as the minimum.

## Options

1. **SwiftUI, iOS 18+.** This is the framework I currently work in. The app is small, with little custom UI, so SwiftUI's defaults (tab bar, push navigation, search, sheets) cover nearly everything. iOS 18 is two versions behind the current iOS 27 and brings the `Tab` API for `TabView`.
2. **SwiftUI, iOS 17+.** Reaches one more year of devices. `@Observable` already works there, but the tab bar would need the older `.tabItem` API.
3. **UIKit.** Gives full control over layout and behavior. That control isn't needed for an app this size, and I haven't worked in UIKit in recent years.

A cross-platform framework was never in scope.

## Decision

Option 1. SwiftUI matches both the size of the app and my current practice. iOS 18 (current minus two) is the lowest version that has the `Tab` API.

## Consequences

- No code lineage: "before" and "after" can only be compared by behavior and screenshots, not by diffs.
- Devices that can't run iOS 18 lose access to new versions. The App Store still offers them the last compatible build (the 2014 app), so they keep what they have today. Since the old app's usage is unknown and probably low, this is acceptable.
- Revisit the minimum if the app needs an API newer than iOS 18, or once iOS 18 falls more than two versions behind.
