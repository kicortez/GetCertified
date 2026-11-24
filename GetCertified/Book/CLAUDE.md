# Book feature

The Book tab holds the user's training list: the trainings they added from Courses. It works much like a shopping cart, except nothing is purchased. Adding a training does **not** book it; booking happens when the user submits a request from this tab. It uses View → Controller → Service layering, like Courses.

- **Service** (`Services/TrainingListService.swift`): `TrainingListServiceProtocol` has one implementation, `TrainingListService`. It stores full `Course` snapshots as JSON at `fileURL`, which defaults to `Application Support/booked-courses.json` (`defaultFileURL`); tests pass a temporary location. The service owns all cart logic: `fetchSelectedCourses()` returns `[]` if the file doesn't exist yet; `save(_:)` is synchronous and writes atomically; `add(_:)` ignores duplicates (by `id`) and `remove(ids:)` removes matches. Both read the file, save right away and return the updated `[Course]`.
- **Booking service** (`Services/BookingService.swift`, `Services/BookingRequest.swift`): `BookingServiceProtocol.submit(_:)` sends a `BookingRequest` (course IDs, contact details, preferred start date, notes) and returns a `BookingConfirmation` with a reference number. The only implementation is `MockBookingService`, which sleeps for `delay` and returns a generated `GC-XXXXXX` reference, or throws when `shouldFail` is set (for previews and tests). This is where a real backend would plug in.
- **Controller** (`Controller/TrainingListController.swift`): an `@Observable` class with no `@MainActor`, because of default isolation. The service is injected through `init` and is `@ObservationIgnored`. It exposes `private(set) var courses`, `contains(_:)`, and async `add(_:)`, `remove(_:)` and `remove(ids:)`, which only forward to the service and assign the returned list. Views call them inside `Task { await ... }`. Errors are only `print`ed.
- **Shared state:** the `App` (`GetCertified.swift`) owns a single `TrainingListController` as `@State`. It injects it with `.environment(_:)` and loads it in `.task` at launch. Views read it with `@Environment(TrainingListController.self)`. Previews must inject one, too.

## View

- `BookView` lists `controller.courses`. The first `Section` is a summary of trainings count, total days and total hours, where days = hours ÷ `hoursPerDay`, which is 8. The summary is at the top because a bottom toolbar clashes with the tab bar. The second `Section`, "Selected Trainings", holds the added rows.
- A "Submit Request" button sits in a bottom `safeAreaInset` above the tab bar. It is disabled while editing. It presents `SubmitRequestView` as a sheet. The `.sheet` is attached at the top of `body`, not to the list, so it stays presented when the training list empties after a successful submit.
- It supports deletion through swipe (`onDelete`) and an Edit button. The Edit button drives a local `EditMode` that is passed down with `.environment(\.editMode, ...)`. Every deletion first goes into `pendingDeletion` and is confirmed with a `confirmationDialog`.
- With no courses, the view shows `ContentUnavailableView`.

## Submit Request

- `SubmitRequestView` owns a `SubmitRequestController` as `@State`, created once from the training list's courses at presentation, and takes the booking service as an init parameter (defaults to `MockBookingService()`).
- `SubmitRequestController` holds the form fields and a `status`: `.editing`, `.submitting`, `.submitted(BookingConfirmation)` or `.failed(String)`. `canSubmit` requires at least one course, a non-empty name and a valid email. Phone, company and notes are optional. The preferred start date defaults to a week out and can't be earlier than tomorrow. Inputs are trimmed when the request is built.
- The form has three sections: Trainings (read-only summary), Contact, and Schedule. While submitting, the Submit toolbar button becomes a `ProgressView`, and the form and swipe-to-dismiss are disabled. A failure shows an alert and returns to the form with the input kept.
- On success, the view clears the submitted courses from the training list with `TrainingListController.remove(ids:)` and swaps the form for a confirmation (`ContentUnavailableView` with the reference number and a Done button).
