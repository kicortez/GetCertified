import SwiftUI

struct CoursesView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var controller = CourseController(service: CourseService())
  @State private var searchText = ""

  private var columns: [GridItem] {
    let count = horizontalSizeClass == .regular ? 3 : 2
    return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
  }

  private var filteredItems: [Course] {
    guard !searchText.isEmpty else { return controller.courses }
    return controller.courses.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(filteredItems) { course in
            NavigationLink(value: course) {
              RoundedRectangle(cornerRadius: 16)
                .fill(.quaternary)
                .aspectRatio(1, contentMode: .fit)
                .overlay { Text(course.name).foregroundStyle(.primary) }
            }
            .buttonStyle(.plain)
          }
        }
        .padding(16)
      }
      .navigationDestination(for: Course.self) { course in
        CourseDetailView(course: course)
      }
      .searchable(text: $searchText)
      .navigationTitle("Courses")
      .task { await controller.fetchCourses() }
    }
  }
}

#Preview {
  CoursesView()
}
