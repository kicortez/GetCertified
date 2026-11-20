# Courses feature

The Courses tab shows the course catalog. It uses View → Controller → Service layering.

- **Service** (`Services/CourseService.swift`): `CourseServiceProtocol` has one implementation, `CourseService`, which decodes the bundled `GetCertified/courses.json` into `[Course]`. The protocol exists so the data source can be replaced, for example with a network client or a mock.
- **Controller** (`Controller/CourseController.swift`): an `@Observable` class. It runs on the main actor through the target's default isolation, so it carries no `@MainActor` annotation. The service is injected through `init`, and the service property is marked `@ObservationIgnored`. The controller exposes `private(set) var courses`. Errors are only `print`ed for now, and there is no loading or error state.
- **Model** (`Services/Course.swift`): `Course` is `Codable`, `Identifiable` and `Hashable`.
  - It is `Hashable` so it can serve as the value for `NavigationLink(value:)` and `.navigationDestination(for: Course.self)`.
  - `type` is either `.regular` or `.certification`, and `certificationKind` applies only to certification courses.
  - The JSON keys match the property names exactly. If you change the model, update `courses.json` too.
  - `image` is currently the string `"placeholder"`, not a real URL.

## Views

- `CoursesView` owns the controller as `@State`. It loads data in `.task { await controller.fetchCourses() }`.
- It shows a `LazyVGrid` with 2 columns in compact width and 3 in regular. `.searchable` filters the grid by name on the client.
- Selecting a course pushes `CourseDetailView`.
- `CourseDetailView` has an "Add to training" button in a bottom `safeAreaInset`. The button's action is still a `// TODO`. It is meant to add the course to Book, as described in the root `CLAUDE.md`.
