# Home

The Home tab uses the View → Controller → Service layering from Courses, with one controller per section. Each service reads a JSON file bundled in `Resources/`, the way `CourseService` reads `courses.json`. To switch a section to another data source, such as a network client, write a new service that conforms to the section's protocol and pass it in where `HomeView` creates the controller.

## Sections

| Section | Model | Data file | Service (protocol) | Controller |
|---|---|---|---|---|
| Hero banner | `HeroBanner` (`title`, `subtitle`) | `hero-banner.json` (one object) | `HeroBannerService` (`HeroBannerServiceProtocol`) | `HeroBannerController.banner` |
| "Popular Courses" / "New Courses" | `Course` (from Courses) | `popular-courses.json` / `new-courses.json` (arrays of course IDs) | `CourseRowService(resource:)` (`CourseRowServiceProtocol`) | `CourseRowController.courses` |
| Tip of the Day | `Tip` (`id`, `text`) | `tips.json` (array) | `TipService` (`TipServiceProtocol`) | `TipController.tip` |

- `BundledJSON.load(_:from:)` (`Services/BundledJSON.swift`) does the bundle lookup and decoding for every Home service.
- `CourseRowService` resolves the IDs in its file against `CourseService` and keeps the file's order. It drops IDs that aren't in `courses.json`, so if you rename a course ID, update these files too.
- `TipService` picks a tip by day of the year (`date` is injectable).
- Each JSON resource name must be unique in the app bundle, because the synchronized folder copies resources flat.
- Controllers follow `CourseController`: `@Observable`, service injected through `init` and `@ObservationIgnored`, `private(set)` state. Errors are only `print`ed, and there's no loading or error state.

## Views

- `HomeView` wraps its content in its own `NavigationStack` with the title "Home", like the other tabs.
- It owns the four controllers as `@State` and loads them concurrently in `.task` (`loadSections()`).
- A vertical `ScrollView` shows the sections top to bottom. The hero text and the tip card render only after their data has loaded. Each course row is a horizontal `ScrollView` that snaps with `.viewAligned` and shows each course's name on a card.
- Each course card is a `NavigationLink(value: course)` with `.buttonStyle(.plain)`. A single `.navigationDestination(for: Course.self)` on the `ScrollView` pushes `CourseDetailView`, the same way `CoursesView` does, so "Add to training" works from Home too.
- Section titles are UI strings in the view (`LocalizedStringKey`). Content strings come from the JSON files.
