import SwiftUI

struct BookView: View {
  @State private var courses: [Course] = BookView.placeholderCourses
  @State private var editMode: EditMode = .inactive
  @State private var pendingDeletion: [Course] = []
  @State private var isConfirmingDelete = false

  private static let hoursPerDay = 8.0

  private var totalHours: Int { courses.reduce(0) { $0 + $1.hours } }
  private var totalDays: Double { Double(totalHours) / Self.hoursPerDay }

  private var totalDaysText: String {
    totalDays.formatted(.number.precision(.fractionLength(0...1)))
  }

  private var confirmationTitle: String {
    if pendingDeletion.count == 1, let course = pendingDeletion.first {
      return "Remove \"\(course.name)\"?"
    }
    return "Remove \(pendingDeletion.count) courses?"
  }

  var body: some View {
    NavigationStack {
      mainContent
        .navigationTitle("Book")
    }
  }
  
  @ViewBuilder
  private var mainContent: some View {
    if courses.isEmpty {
      ContentUnavailableView("No Booked Courses", systemImage: "book")
    } else {
      courseList
    }
  }
  
  private var courseList: some View {
    List {
      ForEach(courses) { course in
        VStack(alignment: .leading, spacing: 4) {
          Text(course.name).font(.headline)
          if let subtitle = course.subtitle {
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
          }
          Text("\(course.hours) hrs · \(course.category)")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
      }
      .onDelete { offsets in
        pendingDeletion = offsets.map { courses[$0] }
        isConfirmingDelete = true
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(editMode.isEditing ? "Done" : "Edit") {
          withAnimation { editMode = editMode.isEditing ? .inactive : .active }
        }
        .disabled(courses.isEmpty)
      }
      ToolbarItem(placement: .bottomBar) { summary }
    }
    .environment(\.editMode, $editMode)
    .confirmationDialog(
      confirmationTitle,
      isPresented: $isConfirmingDelete,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        let ids = Set(pendingDeletion.map(\.id))
        withAnimation { courses.removeAll { ids.contains($0.id) } }
        pendingDeletion = []
        if courses.isEmpty { editMode = .inactive }
      }
      Button("Cancel", role: .cancel) { pendingDeletion = [] }
    }
  }

  private var summary: some View {
    HStack {
      Text("\(courses.count) \(courses.count == 1 ? "training" : "trainings")")
      Spacer()
      Text("\(totalDaysText) \(totalDays == 1 ? "day" : "days") (\(totalHours) hrs)")
    }
    .font(.footnote.weight(.medium))
    .frame(maxWidth: .infinity)
  }
}

extension BookView {
  fileprivate static let placeholderCourses: [Course] = [
    Course(
      id: "book-1", name: "SwiftUI Fundamentals", subtitle: "Build modern iOS interfaces",
      type: .regular, certificationKind: nil, category: "Mobile",
      description: "Placeholder", hours: 16, image: ""),
    Course(
      id: "book-2", name: "AWS Solutions Architect", subtitle: "Associate exam prep",
      type: .certification, certificationKind: "AWS", category: "Cloud",
      description: "Placeholder", hours: 24, image: ""),
    Course(
      id: "book-3", name: "Agile Project Management", subtitle: nil,
      type: .regular, certificationKind: nil, category: "Management",
      description: "Placeholder", hours: 12, image: ""),
    Course(
      id: "book-4", name: "CompTIA Security+", subtitle: "Core security certification",
      type: .certification, certificationKind: "CompTIA", category: "Security",
      description: "Placeholder", hours: 40, image: ""),
  ]
}

#Preview {
  BookView()
}
