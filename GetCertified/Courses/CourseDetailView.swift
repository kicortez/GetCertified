import SwiftUI

struct CourseDetailView: View {
  let course: Course

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
    .safeAreaInset(edge: .bottom) {
      Button {
        // TODO: add to training
      } label: {
        Text("Add to training")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .padding(16)
      .background(.bar)
    }
    .navigationTitle(course.name)
    .navigationBarTitleDisplayMode(.inline)
  }
}
