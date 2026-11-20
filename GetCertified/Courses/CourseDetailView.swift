import SwiftUI

struct CourseDetailView: View {
  let course: Course

  @Environment(BookController.self) private var bookController

  private var isAdded: Bool { bookController.contains(course) }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        AsyncImage(url: URL(string: course.image)) { image in
          image.resizable().scaledToFill()
        } placeholder: {
          Rectangle().fill(.quaternary)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))

        VStack(alignment: .leading, spacing: 4) {
          Text(course.name).font(.title).bold()
          if let subtitle = course.subtitle {
            Text(subtitle).font(.headline).foregroundStyle(.secondary)
          }
        }

        VStack(alignment: .leading, spacing: 8) {
          Label(course.category, systemImage: "tag")
          if course.type == .certification {
            Label(course.certificationKind ?? "Certification", systemImage: "checkmark.seal")
          }
          Label("\(course.hours) hours", systemImage: "clock")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)

        Text(course.description)
          .font(.body)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(16)
    }
    .safeAreaInset(edge: .bottom) { addButton }
    .navigationTitle(course.name)
    .navigationBarTitleDisplayMode(.inline)
  }

  private var addButton: some View {
    Group {
      if isAdded {
        Button(role: .destructive) {
          Task { await bookController.remove(course) }
        } label: {
          Text("Remove from training").frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
      } else {
        Button {
          Task { await bookController.add(course) }
        } label: {
          Text("Add to training").frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .controlSize(.large)
    .padding(16)
    .background(.bar)
  }
}
