import SwiftUI

struct CoursesView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var controller = CourseController(service: CourseService())
  @State private var searchText = ""

  private var columns: [GridItem] {
    let count = horizontalSizeClass == .regular ? 3 : 2
    return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
  }

  private func filteredItems(_ courses: [Course]) -> [Course] {
    guard !searchText.isEmpty else { return courses }
    return courses.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
  }

  var body: some View {
    NavigationStack {
      content
        .navigationDestination(for: Course.self) { course in
          CourseDetailView(course: course)
        }
        .navigationTitle("Courses")
        .task { await controller.fetchCourses() }
    }
  }

  @ViewBuilder
  private var content: some View {
    switch controller.state {
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .success(let courses) where courses.isEmpty:
      ContentUnavailableView("No Courses", systemImage: "books.vertical")
    case .success(let courses):
      grid(courses)
    case .error(let message):
      errorView(message)
    }
  }

  private func grid(_ courses: [Course]) -> some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 16) {
        ForEach(filteredItems(courses)) { course in
          NavigationLink(value: course) {
            RoundedRectangle(cornerRadius: 16)
              .fill(.tint.quaternary)
              .aspectRatio(1, contentMode: .fit)
              .overlay { Text(course.name).foregroundStyle(.primary) }
          }
          .buttonStyle(.plain)
        }
      }
      .padding(16)
    }
    .searchable(text: $searchText)
  }

  private func errorView(_ message: String) -> some View {
    ContentUnavailableView {
      Label("Couldn't Load Courses", systemImage: "exclamationmark.triangle")
    } description: {
      Text(message)
    } actions: {
      Button("Try Again") {
        Task { await controller.fetchCourses() }
      }
      .buttonStyle(.borderedProminent)
    }
  }
}
