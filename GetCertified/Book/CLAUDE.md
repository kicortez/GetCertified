# Book feature

The Book tab works like a shopping cart. It lists the trainings the user has added from Courses. Adding a training does **not** book it; booking happens when the user submits a request from this tab. It uses View → Controller → Service layering, like Courses.

- **Service** (`Services/BookService.swift`): `BookServiceProtocol` has one implementation, `BookService`. It stores full `Course` snapshots as JSON in `Application Support/booked-courses.json`. The service owns all cart logic: `fetchSelectedCourses()` returns `[]` if the file doesn't exist yet; `save(_:)` is synchronous and writes atomically; `add(_:)` ignores duplicates (by `id`) and `remove(ids:)` removes matches. Both read the file, save right away and return the updated `[Course]`.
- **Controller** (`Controller/BookController.swift`): an `@Observable` class with no `@MainActor`, because of default isolation. The service is injected through `init` and is `@ObservationIgnored`. It exposes `private(set) var courses`, `contains(_:)`, and async `add(_:)`, `remove(_:)` and `remove(ids:)`, which only forward to the service and assign the returned list. Views call them inside `Task { await ... }`. Errors are only `print`ed.
- **Shared state:** the `App` (`GetCertified.swift`) owns a single `BookController` as `@State`. It injects it with `.environment(_:)` and loads it in `.task` at launch. Views read it with `@Environment(BookController.self)`. Previews must inject one, too.

## View

- `BookView` lists `controller.courses`. The first `Section` is a summary of trainings count, total days and total hours, where days = hours ÷ `hoursPerDay`, which is 8. The summary is at the top because a bottom toolbar clashes with the tab bar. The second `Section`, "Selected Trainings", holds the added rows.
- A "Submit Request" button sits in a bottom `safeAreaInset` above the tab bar. Its action is still a `// TODO`. It is disabled while editing.
- It supports deletion through swipe (`onDelete`) and an Edit button. The Edit button drives a local `EditMode` that is passed down with `.environment(\.editMode, ...)`. Every deletion first goes into `pendingDeletion` and is confirmed with a `confirmationDialog`.
- With no courses, the view shows `ContentUnavailableView`.
