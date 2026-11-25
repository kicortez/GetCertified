import SwiftUI

struct BookView: View {
  @Environment(TrainingListController.self) private var controller
  @State private var editMode: EditMode = .inactive
  @State private var pendingDeletion: [TrainingListItem] = []
  @State private var isConfirmingDelete = false
  @State private var isPresentingSubmit = false

  private static let hoursPerDay = 8.0

  private var items: [TrainingListItem] { controller.items }
  private var totalHours: Int { items.reduce(0) { $0 + $1.hours } }
  private var totalDays: Double { Double(totalHours) / Self.hoursPerDay }

  private var totalDaysText: String {
    totalDays.formatted(.number.precision(.fractionLength(0...1)))
  }

  private var confirmationTitle: String {
    if pendingDeletion.count == 1, let item = pendingDeletion.first {
      return "Remove \"\(item.name)\"?"
    }
    return "Remove \(pendingDeletion.count) courses?"
  }

  var body: some View {
    NavigationStack {
      mainContent
        .navigationTitle("Book")
    }
    .sheet(isPresented: $isPresentingSubmit) {
      SubmitRequestView(items: items)
    }
  }

  @ViewBuilder
  private var mainContent: some View {
    if items.isEmpty {
      ContentUnavailableView(
        "No Trainings Added",
        systemImage: "book",
        description: Text("Add trainings from Courses to see them here."))
    } else {
      trainingList
    }
  }

  private var trainingList: some View {
    List {
      Section { summary }
      Section("Selected Trainings") {
        ForEach(items) { item in
          itemRow(item)
        }
        .onDelete { offsets in
          pendingDeletion = offsets.map { items[$0] }
          isConfirmingDelete = true
        }
      }
    }
    .animation(.default, value: items)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(editMode.isEditing ? "Done" : "Edit") {
          withAnimation { editMode = editMode.isEditing ? .inactive : .active }
        }
        .disabled(items.isEmpty)
      }
    }
    .safeAreaInset(edge: .bottom) { submitButton }
    .environment(\.editMode, $editMode)
    .confirmationDialog(
      confirmationTitle,
      isPresented: $isConfirmingDelete,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        let ids = Set(pendingDeletion.map(\.id))
        pendingDeletion = []
        Task {
          await controller.remove(ids: ids)
          if items.isEmpty { editMode = .inactive }
        }
      }
      Button("Cancel", role: .cancel) { pendingDeletion = [] }
    }
  }

  private var submitButton: some View {
    Button {
      isPresentingSubmit = true
    } label: {
      Text("Submit Request").frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .disabled(editMode.isEditing)
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

  private var summary: some View {
    HStack {
      summaryItem(value: "\(items.count)", label: items.count == 1 ? "Training" : "Trainings")
      Divider()
      summaryItem(value: totalDaysText, label: totalDays == 1 ? "Day" : "Days")
      Divider()
      summaryItem(value: "\(totalHours)", label: totalHours == 1 ? "Hour" : "Hours")
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
}
