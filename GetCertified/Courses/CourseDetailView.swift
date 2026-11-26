import SwiftUI

struct CourseDetailView: View {
  let course: Course

  @Environment(TrainingListController.self) private var trainingListController

  /// Whether the course is in the list from the last successful service call. Kept here so a
  /// later `.loading` or `.error` doesn't flip the button.
  @State private var isAdded = false

  /// The message of a failed add or remove made from this view.
  @State private var errorMessage: String?

  private var isLoading: Bool { trainingListController.state == .loading }

  private var isShowingError: Binding<Bool> {
    Binding(
      get: { errorMessage != nil },
      set: { if !$0 { errorMessage = nil } })
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        AsyncImage(url: URL(string: course.image)) { image in
          image.resizable().scaledToFill()
        } placeholder: {
          Rectangle().fill(.tint.quaternary)
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
    .alert("Couldn't Update Training List", isPresented: isShowingError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(errorMessage ?? "")
    }
    .onChange(of: trainingListController.state, initial: true) { _, state in
      if case .success(let list) = state {
        isAdded = list.items.contains { $0.id == course.id }
      }
    }
  }

  private var addButton: some View {
    Group {
      if isAdded {
        Button(role: .destructive) {
          Task { await perform { await trainingListController.remove(ids: [course.id]) } }
        } label: {
          buttonLabel("Remove from training")
        }
        .buttonStyle(.bordered)
      } else {
        Button {
          Task { await perform { await trainingListController.add(course) } }
        } label: {
          buttonLabel("Add to training")
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .disabled(isLoading)
    .controlSize(.large)
    .padding(16)
    .background(.bar)
  }

  private func buttonLabel(_ title: LocalizedStringKey) -> some View {
    ZStack {
      Text(title).opacity(isLoading ? 0 : 1)
      if isLoading { ProgressView() }
    }
    .frame(maxWidth: .infinity)
  }

  // MARK: - Actions

  /// Runs a training list change and, if it fails, reports it here.
  private func perform(_ change: () async -> Void) async {
    await change()
    if case .error(let message) = trainingListController.state { errorMessage = message }
  }
}
