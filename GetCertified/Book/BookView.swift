import SwiftUI

struct BookView: View {
  @Environment(TrainingListController.self) private var controller
  @State private var isPresentingSubmit = false

  /// The list from the last successful service call. Kept here so a later `.loading` or `.error`
  /// doesn't clear the screen. `nil` until the first success.
  @State private var list: TrainingList?

  /// The message of a failed change made from this view, shown in an alert over the kept list.
  @State private var errorMessage: String?

  private var items: [TrainingListItem] { list?.items ?? [] }
  private var summary: TrainingList.Summary { list?.summary ?? .zero }

  private var daysText: String {
    summary.days.formatted(.number.precision(.fractionLength(0...1)))
  }

  private var isLoading: Bool { controller.state == .loading }

  private var isShowingError: Binding<Bool> {
    Binding(
      get: { errorMessage != nil },
      set: { if !$0 { errorMessage = nil } })
  }

  var body: some View {
    NavigationStack {
      mainContent
        .overlay { if isLoading { loadingOverlay } }
        .animation(.default, value: isLoading)
        .navigationTitle("Book")
    }
    .sheet(isPresented: $isPresentingSubmit) {
      SubmitRequestView(list: list ?? .empty)
    }
    .alert("Couldn't Update Training List", isPresented: isShowingError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(errorMessage ?? "")
    }
    .onChange(of: controller.state, initial: true) { _, state in
      if case .success(let newList) = state { list = newList }
    }
  }

  @ViewBuilder
  private var mainContent: some View {
    if list == nil {
      firstLoadContent
    } else if items.isEmpty {
      ContentUnavailableView(
        "No Trainings Added",
        systemImage: "book",
        description: Text("Add trainings from Courses to see them here."))
    } else {
      trainingList
    }
  }

  /// Shown before any list has loaded: blank under the loading overlay, or the load error.
  @ViewBuilder
  private var firstLoadContent: some View {
    if case .error(let message) = controller.state {
      errorView(message)
    } else {
      Color.clear
    }
  }

  /// Dims the content and blocks touches beneath it, so the user can't swipe or submit mid-call.
  private var loadingOverlay: some View {
    ZStack {
      Rectangle().fill(.background.opacity(0.6))
      ProgressView().controlSize(.large)
    }
    .ignoresSafeArea()
    .transition(.opacity)
  }

  private func errorView(_ message: String) -> some View {
    ContentUnavailableView {
      Label("Couldn't Load Training List", systemImage: "exclamationmark.triangle")
    } description: {
      Text(message)
    } actions: {
      Button("Try Again") {
        Task { await controller.fetch() }
      }
      .buttonStyle(.borderedProminent)
    }
  }

  private var trainingList: some View {
    List {
      Section { summaryRow }
      Section("Selected Trainings") {
        ForEach(items) { item in
          itemRow(item)
        }
        .onDelete { offsets in
          let ids = Set(offsets.map { items[$0].id })
          Task { await remove(ids: ids) }
        }
      }
    }
    .animation(.default, value: items)
    .safeAreaInset(edge: .bottom) { submitButton }
  }

  private var submitButton: some View {
    Button {
      isPresentingSubmit = true
    } label: {
      Text("Submit Request").frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .padding(16)
    .background(.bar)
  }

  private func itemRow(_ item: TrainingListItem) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(item.name).font(.headline)
      if let subtitle = item.subtitle {
        Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
      }
      Text("\(item.hours) hrs · \(item.category)")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 2)
  }

  private var summaryRow: some View {
    HStack {
      summaryItem(value: "\(summary.count)", label: summary.count == 1 ? "Training" : "Trainings")
      Divider()
      summaryItem(value: daysText, label: summary.days == 1 ? "Day" : "Days")
      Divider()
      summaryItem(value: "\(summary.hours)", label: summary.hours == 1 ? "Hour" : "Hours")
    }
    .padding(.vertical, 4)
  }

  private func summaryItem(value: String, label: LocalizedStringKey) -> some View {
    VStack(spacing: 2) {
      Text(value).font(.title3.bold()).monospacedDigit()
      Text(label).font(.caption).foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
  }

  // MARK: - Actions

  /// Removes the rows and, if the call fails, reports it here. The kept list stays on screen.
  private func remove(ids: Set<TrainingListItem.ID>) async {
    await controller.remove(ids: ids)
    if case .error(let message) = controller.state { errorMessage = message }
  }
}
