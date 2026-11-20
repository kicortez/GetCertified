# Book feature

The Book tab lists the courses the user has booked. All of it lives in `BookView.swift`.

- It has no controller or service yet. Its courses come from a hard-coded `placeholderCourses` array of `Course`s held in local `@State`. When it gets real data, give it the same controller and service layering that Courses uses.
- It supports deletion through swipe (`onDelete`) and an Edit button. The Edit button drives a local `EditMode` that is passed down with `.environment(\.editMode, ...)`. Every deletion first goes into `pendingDeletion` and is confirmed with a `confirmationDialog`.
- A bottom-bar summary shows total hours and total days, where days = hours ÷ `hoursPerDay`, which is 8.
- With no courses, the view shows `ContentUnavailableView` and disables the Edit button.
