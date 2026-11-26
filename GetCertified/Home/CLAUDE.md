# Home

The Home tab uses the View → Controller → Service layering from Courses, with one controller per section. Each service reads a JSON file bundled in `Resources/`, the way `CourseService` reads `courses.json`. To switch a section to another data source, such as a network client, write a new service that conforms to the section's protocol and pass it in where `HomeView` creates the controller.

## Sections

| Section | Model | Data file | Service (protocol) | Controller |
|---|---|---|---|---|
| Hero banner | `HeroBanner` (`title`, `subtitle`) | `hero-banner.json` (one object) | `HeroBannerService` (`HeroBannerServiceProtocol`) | `HeroBannerController.state` (`LoadState<HeroBanner>`) |
| "Popular Courses" / "New Courses" | `Course` (from Courses) | `popular-courses.json` / `new-courses.json` (arrays of course IDs) | `CourseRowService(resource:)` (`CourseRowServiceProtocol`) | `CourseRowController.state` (`LoadState<[Course]>`) |
| Tip of the Day | `Tip` (`id`, `text`) | `tips.json` (array) | `TipService` (`TipServiceProtocol`) | `TipController.state` (`LoadState<Tip>`) |

- `BundledJSON.load(_:from:)` (`Services/BundledJSON.swift`) does the bundle lookup and decoding for every Home service.
- `CourseRowService` resolves the IDs in its file against `CourseService` and keeps the file's order. It drops IDs that aren't in `courses.json`, so if you rename a course ID, update these files too.
- `TipService` picks a tip by day of the year (`date` is injectable).
- Each JSON resource name must be unique in the app bundle, because the synchronized folder copies resources flat.
- Controllers follow `CourseController`: `@Observable`, service injected through `init` and `@ObservationIgnored`, `private(set) var state` of the shared `LoadState` (`Shared/LoadState.swift`). Each fetch sets `.loading` first, then `.success` or `.error` with the error's `localizedDescription` (see `docs/decisions/0013-shared-load-state.md`).

## Views

- `HomeView` wraps its content in its own `NavigationStack` with the title "Home", like the other tabs.
- It owns the four controllers as `@State` and loads them concurrently in `.task` (`loadSections()`).
- A vertical `ScrollView` shows the sections top to bottom. Each section switches on its own controller's `state`, so one failed section doesn't hide the others: `.loading` shows a `ProgressView`, `.error` shows the shared `sectionError` (a `ContentUnavailableView` with the message and a "Try Again" button that refetches only that section), and `.success` shows the content. A course row whose `.success` array is empty shows a "No Courses" `ContentUnavailableView`. Section headers always show; the hero's spinner and error sit inside the gradient frame. Each course row is a horizontal `ScrollView` that snaps with `.viewAligned` and shows each course's name on a card.
- Each course card is a `NavigationLink(value: course)` with `.buttonStyle(.plain)`. A single `.navigationDestination(for: Course.self)` on the `ScrollView` pushes `CourseDetailView`, the same way `CoursesView` does, so "Add to training" works from Home too.
- Section titles are UI strings in the view (`LocalizedStringKey`). Content strings come from the JSON files.
